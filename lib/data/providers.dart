import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/app/graphql_config.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/services/comment_service.dart';
import 'package:sagelink_communities/data/services/post_service.dart';
import 'package:sagelink_communities/data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

////////////////////////////////////////
// API providers                      //
////////////////////////////////////////
final gqlConfigProvider = ChangeNotifierProvider((ref) {
  var gqlConfig = GraphQLConfiguration();
  final authState = ref.watch(authStateChangesProvider);
  final auth = ref.watch(authProvider);
  authState.when(
      data: (user) async {
        if (user != null) {
          var token = await auth.getJWT();
          token != null ? gqlConfig.setToken(token) : gqlConfig.removeToken();
        } else {
          gqlConfig.removeToken();
        }
      },
      error: (e, trace) => gqlConfig.removeToken(),
      loading: () => {});
  return gqlConfig;
});

final gqlClientProvider = Provider((ref) {
  final config = ref.watch(gqlConfigProvider);
  return ValueNotifier(config.client);
});

final commentServiceProvider = Provider((ref) => CommentService(
    client: ref.watch(gqlClientProvider).value,
    user: ref.watch(loggedInUserProvider)));

final postServiceProvider = Provider((ref) => PostService(
    client: ref.watch(gqlClientProvider).value,
    user: ref.watch(loggedInUserProvider)));

final userServiceProvider = Provider((ref) => UserService(
    client: ref.watch(gqlClientProvider).value,
    authUser: ref.watch(loggedInUserProvider)));

////////////////////////////////////////
// Auth providers                     //
////////////////////////////////////////

final loggedInUserProvider =
    StateNotifierProvider<LoggedInUserStateNotifier, LoggedInUser>((ref) {
  final client = ref.watch(gqlClientProvider);
  final gqlConfig = ref.watch(gqlConfigProvider);
  final authState = ref.watch(authStateChangesProvider);

  var notifier =
      LoggedInUserStateNotifier(LoggedInUser(), client: client.value);

  authState.when(
      data: (user) {
        gqlConfig.isAuthenticated ? notifier.updateUserWithState(user) : {};
      },
      error: (e, trace) => notifier.updateUserWithState(null),
      loading: () => notifier.setIsLoading());

  return notifier;
});

final authProvider = Provider((ref) => Authentication());

final authStateChangesProvider =
    StreamProvider<User?>((ref) => Authentication().idTokenChanges);

////////////////////////////////////////
// App state providers                //
////////////////////////////////////////

final sharedPrefs = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

final appStateProvider = StateNotifierProvider<AppState, AppStateStatus>((ref) {
  final prefs = ref.watch(sharedPrefs).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
  return AppState(prefs);
});
