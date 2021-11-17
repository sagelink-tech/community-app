import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoginState {
  isLoggedOut,
  isLoggingIn,
  isLoggedIn,
}

class LoggedInUser {
  String userId = "";
  LoginState status = LoginState.isLoggedOut;

  LoggedInUser({this.userId = "", this.status = LoginState.isLoggedOut});
}

class LoggedInUserStateNotifier extends StateNotifier<LoggedInUser> {
  LoggedInUserStateNotifier(state) : super(state ?? LoggedInUser());

  void loginWithUserId(String userId) {
    print('logging in');
    final user = LoggedInUser(userId: userId, status: LoginState.isLoggedIn);
    state = user;
  }

  void logout() {
    print('logging out');
    final user = LoggedInUser();
    state = user;
  }
}
