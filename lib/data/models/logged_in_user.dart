import 'package:flutter/material.dart';
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
}

class LoggedInUser {
  UserModel? user;
  LoginState status = LoginState.isLoggedOut;
  bool isAdmin = false;
  String? adminBrandId;

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
  LoggedInUserStateNotifier(state) : super(state ?? LoggedInUser());

  void loginWithUserId(GraphQLClient client, String userId) async {
    state = LoggedInUser(user: null, status: LoginState.isLoggingIn);

    final QueryResult result = await client.query(QueryOptions(
      document: gql(getUserQuery),
      variables: {
        "where": {"id": userId},
        "options": {"limit": 1}
      },
    ));
    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      var _userData = result.data?['users'][0];
      UserModel _user = UserModel.fromJson(_userData);
      String? brandId;
      bool isAdmin = false;

      if ((_userData['employeeOfBrandsConnection']['edges'] as List)
          .isNotEmpty) {
        brandId =
            _userData['employeeOfBrandsConnection']['edges'][0]['node']['id'];
      }
      LoggedInUser _loggedInUser = LoggedInUser(
          user: _user,
          status: LoginState.isLoggedIn,
          isAdmin: isAdmin,
          adminBrandId: brandId);
      state = _loggedInUser;
    }
  }

  void loginWithEmail(
      GraphQLClient client, String userEmail, BuildContext context) async {
    state = LoggedInUser(user: null, status: LoginState.isLoggingIn);

    final QueryResult result = await client.query(QueryOptions(
      document: gql(getUserQuery),
      variables: {
        "where": {"email": userEmail},
        "options": {"limit": 1}
      },
    ));
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
      LoggedInUser _loggedInUser =
          LoggedInUser(user: null, status: LoginState.isLoggedOut);
      state = _loggedInUser;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            (result.exception ?? Exception("Error signing in")).toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  void logout() {
    LoggedInUser _loggedInUser =
        LoggedInUser(user: UserModel(), status: LoginState.isLoggedOut);
    state = _loggedInUser;
  }
}
