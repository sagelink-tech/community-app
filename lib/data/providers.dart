import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/app/app_config.dart';
import 'package:sagelink_communities/app/graphql_config.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/services/comment_service.dart';
import 'package:sagelink_communities/data/services/post_service.dart';
import 'package:sagelink_communities/data/services/user_service.dart';

////////////////////////////////////////
// API providers                      //
////////////////////////////////////////

final gqlClientProvider = ChangeNotifierProvider((ref) {
  final Authentication auth = ref.watch(authProvider);
  auth.authInstance.authStateChanges().listen((User? user) async {
    if (user != null) {
      String? token = await auth.getJWT();
      token != null
          ? GraphQLConfiguration.setToken(token)
          : GraphQLConfiguration.removeToken();
    } else {
      GraphQLConfiguration.removeToken();
    }
  });
  return GraphQLConfiguration().client;
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
  final auth = ref.watch(authProvider);
  final client = ref.watch(gqlClientProvider);

  var notifier = LoggedInUserStateNotifier(LoggedInUser(user: UserModel()),
      client: client.value);

  auth.authInstance.userChanges().listen((User? user) {
    notifier.updateUserWithState(user);
  });
  return notifier;
});

final authProvider = Provider((ref) => Authentication());

final authStateChangesProvider =
    StreamProvider<User?>((ref) => Authentication().authStateChange);

////////////////////////////////////////
// App state providers                //
////////////////////////////////////////
final appStateProvider = ChangeNotifierProvider((ref) => AppState());
