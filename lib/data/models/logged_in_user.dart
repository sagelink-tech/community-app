import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/app/graphql_config.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
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

class LoggedInUser extends ChangeNotifier {
  UserModel? user;
  LoginState status = LoginState.isLoggedOut;
  bool isAdmin = false;
  String? adminBrandId;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  // Main use case interfaces
  UserModel getUser() {
    return user ?? UserModel();
  }

  LoggedInUser(this.authState, this.gqlConfig,
      {this.user,
      this.status = LoginState.isLoggedOut,
      this.isAdmin = false,
      this.adminBrandId});
// }

// class LoggedInUserStateNotifier extends StateNotifier<LoggedInUser> {
//   LoggedInUserStateNotifier(state,
//       {required this.gqlConfig, required this.authState})
//       : super(state ?? LoggedInUser());

  static final provider = ChangeNotifierProvider<LoggedInUser>((ref) {
    final gqlConfig = ref.watch(gqlConfigurationProvider);
    final authState = ref.watch(authProvider);
    final authChanges = ref.watch(authStateChangesProvider);

    LoggedInUser loggedInUser = LoggedInUser(authState, gqlConfig);

    authChanges.when(
        data: (user) async {
          //print(user);
          if (authState.isAuthenticated) {
            if (!gqlConfig.isAuthenticated) {}
          }
          loggedInUser.updateUserWithState(user);
        },
        error: (e, trace) => loggedInUser.updateUserWithState(null),
        loading: () => loggedInUser.setIsLoggingIn());

    return loggedInUser;
  });

  final GraphQLConfiguration gqlConfig;
  final AuthState authState;

  void updateUserWithState(User? user) {
    if (user != null) {
      fetchUserData(firebaseUser: user);
    } else if (user == null) {
      logout();
    }
  }

  void logout() {
    user = null;
    status = LoginState.isLoggedOut;
    notifyListeners();
  }

  void setIsLoggingIn() {
    user = null;
    status = LoginState.isLoggingIn;
    notifyListeners();
  }

  // Fetch logged in user's data from the SL backend
  Future<void> fetchUserData({User? firebaseUser, String? userId}) async {
    if (firebaseUser == null && userId == null) {
      throw ("Need either user or userid to fetch");
    }

    if (!gqlConfig.isAuthenticated) {
      return;
    }
    setIsLoggingIn();
    final QueryResult result = await gqlConfig.client.query(QueryOptions(
      document: gql(getUserQuery),
      variables: {
        "where":
            userId != null ? {"id": userId} : {"firebaseId": firebaseUser!.uid},
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
      bool isAdminFlag = false;

      if ((_userData['employeeOfBrandsConnection']['edges'] as List)
          .isNotEmpty) {
        isAdmin = true;
        brandId =
            _userData['employeeOfBrandsConnection']['edges'][0]['node']['id'];
      }
      user = _user;
      status = LoginState.isLoggedIn;
      isAdmin = isAdminFlag;
      adminBrandId = brandId;
      notifyListeners();
    } else {
      if (firebaseUser != null) {
        user = UserModel.fromFirebaseUser(firebaseUser);
        status = LoginState.needToCreateUser;
        notifyListeners();
      } else {
        throw ("Error fetching user data with userid: " + userId!);
      }
    }
  }

  void updateWithUserId(String userId) {
    user = UserModel();
    status = LoginState.isLoggingIn;
    notifyListeners();
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
