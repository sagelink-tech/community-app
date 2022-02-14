import 'package:firebase_auth/firebase_auth.dart';
import 'package:sagelink_communities/app/graphql_config.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
        node {
          id
        }
      }
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

  final GraphQLConfiguration gqlConfig;

  void updateUserWithState(User? user) {
    print(user);
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
  Future<void> fetchUserData({required User user}) async {
    print("fetching user");
    print("ISAUTHCHECK: " + gqlConfig.isAuthenticated.toString());
    if (!gqlConfig.isAuthenticated) {
      return;
    }
    state = LoggedInUser(user: null, status: LoginState.isLoggingIn);
    final QueryResult result = await gqlConfig.client.query(QueryOptions(
      document: gql(getUserQuery),
      variables: {
        "where": {"firebaseId": user.uid},
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
      // need to create user
      state = LoggedInUser(
          user: UserModel.fromFirebaseUser(user),
          status: LoginState.needToCreateUser);
    }
  }

  // Create a new user on the SL backend
  UserModel? createUserWithData() {
    return null;
  }
}
