import 'package:community_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getUserQuery = """
query Users(\$where: UserWhere) {
  users(where: \$where) {
    id
    username
    email
    name
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
  bool isAdmin = true;

  UserModel getUser() {
    return user ?? UserModel();
  }

  LoggedInUser({this.user, this.status = LoginState.isLoggedOut});
}

class LoggedInUserStateNotifier extends StateNotifier<LoggedInUser> {
  LoggedInUserStateNotifier(state) : super(state ?? LoggedInUser());

  void loginWithUserId(GraphQLClient client, String userId) async {
    state.status = LoginState.isLoggingIn;

    final QueryResult result = await client.query(QueryOptions(
      document: gql(getUserQuery),
      variables: {
        "where": {"id": userId},
        "options": {"limit": 1}
      },
    ));
    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      UserModel _user = UserModel.fromJson(result.data?['users'][0]);
      LoggedInUser _loggedInUser =
          LoggedInUser(user: _user, status: LoginState.isLoggedIn);
      state = _loggedInUser;
    }
  }

  void logout() {
    LoggedInUser _loggedInUser =
        LoggedInUser(user: UserModel(), status: LoginState.isLoggedOut);
    state = _loggedInUser;
  }
}
