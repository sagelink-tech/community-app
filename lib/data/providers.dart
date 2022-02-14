import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/app/graphql_config.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/services/comment_service.dart';
import 'package:sagelink_communities/data/services/post_service.dart';
import 'package:sagelink_communities/data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

////////////////////////////////////////
// API providers                      //
////////////////////////////////////////
final gqlConfigurationProvider = GraphQLConfigurationNotifier.provider;

final gqlClientProvider = Provider((ref) {
  final config = ref.watch(GraphQLConfigurationNotifier.provider);
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
    authNotifier: ref.watch(loggedInUserProvider.notifier),
    authUser: ref.watch(loggedInUserProvider)));

////////////////////////////////////////
// Auth providers                     //
////////////////////////////////////////

final authProvider = AuthStateNotifier.provider;
final authNotifier = AuthStateNotifier.provider.notifier;
final authStateChangesProvider =
    StreamProvider<User?>((ref) => ref.watch(authNotifier).idTokenChanges);

final loggedInUserProvider = LoggedInUserStateNotifier.provider;

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
