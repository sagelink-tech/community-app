import 'package:firebase_auth/firebase_auth.dart';
import 'package:sagelink_communities/app/graphql_config.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/providers.dart';

String getUserQuery = """
query Users(\$where: UserWhere) {
  users(where: \$where) {
    id
    email
    name
    accountPictureUrl
    employeeOfBrandsConnection {
      edges {
        roles
        inviteEmail
        jobTitle
        owner
        founder
        node {
          id
          name
          logoUrl
          mainColor
        }
      }
    }
    memberOfBrandsConnection {
      edges {
        tier
        inviteEmail
        customerId
        node {
          id
          name
          logoUrl
          mainColor
        }
      }
    }
  }
}
""";

//ignore: constant_identifier_names
const String CREATE_USER_MUTATION = """
mutation CreateUsers(\$input: [UserCreateInput!]!) {
  createUsers(input: \$input) {
    users {
      id
    }
  }
}
""";

enum LoginState {
  isLoggedOut,
  isLoggingIn,
  isLoggedIn,
  needToCreateUser,
}

class LoggedInUser {
  UserModel? user;
  LoginState status = LoginState.isLoggedOut;
  bool isAdmin = false;
  String? adminBrandId;

  // Main use case interfaces
  UserModel getUser() {
    return user ?? UserModel();
  }

  LoggedInUser(
      {this.user,
      this.status = LoginState.isLoggedOut,
      this.isAdmin = false,
      this.adminBrandId});
}

class LoggedInUserStateNotifier extends StateNotifier<LoggedInUser> {
  LoggedInUserStateNotifier(state, {required this.gqlConfig})
      : super(state ?? LoggedInUser());

  static final provider =
      StateNotifierProvider<LoggedInUserStateNotifier, LoggedInUser>((ref) {
    final gqlConfig = ref.watch(GraphQLConfigurationNotifier.provider);
    final authState = ref.watch(authStateChangesProvider);

    var notifier = LoggedInUserStateNotifier(LoggedInUser(user: null),
        gqlConfig: gqlConfig);

    authState.when(
        data: (user) {
          notifier.updateUserWithState(user);
        },
        error: (e, trace) => notifier.updateUserWithState(null),
        loading: () => notifier.setIsLoggingIn());

    return notifier;
  });

  final GraphQLConfiguration gqlConfig;

  void updateUserWithState(User? user) {
    if (user != null) {
      fetchUserData(user: user);
    } else if (user == null) {
      logout();
    }
  }

  void logout() {
    LoggedInUser _user =
        LoggedInUser(user: null, status: LoginState.isLoggedOut);
    state = _user;
  }

  void setIsLoggingIn() {
    LoggedInUser _user =
        LoggedInUser(user: null, status: LoginState.isLoggingIn);
    state = _user;
  }

  // Fetch logged in user's data from the SL backend
  Future<void> fetchUserData({User? user, String? userId}) async {
    if (user == null && userId == null) {
      throw ("Need either user or userid to fetch");
    }

    if (!gqlConfig.isAuthenticated) {
      return;
    }
    state = LoggedInUser(user: null, status: LoginState.isLoggingIn);
    final QueryResult result = await gqlConfig.client.query(QueryOptions(
      document: gql(getUserQuery),
      variables: {
        "where": userId != null ? {"id": userId} : {"firebaseId": user!.uid},
        "options": {"limit": 1}
      },
    ));
    if (result.hasException) {
      throw (result.exception!);
    }

    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      var _userData = result.data?['users'][0];
      UserModel _user = UserModel.fromJson(_userData);
      String? brandId;
      bool isAdmin = false;

      if ((_userData['employeeOfBrandsConnection']['edges'] as List)
          .isNotEmpty) {
        isAdmin = true;
        brandId =
            _userData['employeeOfBrandsConnection']['edges'][0]['node']['id'];
      }
      LoggedInUser _loggedInUser = LoggedInUser(
          user: _user,
          status: LoginState.isLoggedIn,
          isAdmin: isAdmin,
          adminBrandId: brandId);
      state = _loggedInUser;
    } else {
      if (user != null) {
        state = LoggedInUser(
            user: UserModel.fromFirebaseUser(user),
            status: LoginState.needToCreateUser);
      } else {
        throw ("Error fetching user data with userid: " + userId!);
      }
    }
  }

  void updateWithUserId(String userId) {
    state = LoggedInUser(user: UserModel(), status: LoginState.isLoggingIn);
    fetchUserData(userId: userId);
  }

  void createNewUser(UserModel user, {OnMutationCompleted? onComplete}) async {
    // initialize mutation variables
    Map<String, dynamic> mutationVariables = user.toJson();
    mutationVariables.remove('id');
    mutationVariables["causes"] = {
      "connectOrCreate": user.causes
          .map((e) => {
                "where": {
                  "node": {"title": e.title}
                },
                "onCreate": {
                  "node": {"title": e.title}
                }
              })
          .toList()
    };

    // Update
    MutationOptions options =
        MutationOptions(document: gql(CREATE_USER_MUTATION), variables: {
      "input": [mutationVariables]
    });

    QueryResult result = await gqlConfig.client.mutate(options);

    bool success = (result.data != null &&
        (result.data!['createUsers']['users'] as List).length == 1);
    if (success) {
      updateWithUserId(result.data!['createUsers']['users'][0]['id']);
    }
    if (onComplete != null) {
      onComplete(result.data);
    }
  }
}
