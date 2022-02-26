import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/app/app_config.dart';
import 'package:sagelink_communities/app/graphql_config.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/data/models/firebase_messaging_model.dart';
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
    analytics: ref.watch(analyticsProvider),
    client: ref.watch(gqlClientProvider).value,
    user: ref.watch(loggedInUserProvider)));

final postServiceProvider = Provider((ref) => PostService(
    analytics: ref.watch(analyticsProvider),
    client: ref.watch(gqlClientProvider).value,
    user: ref.watch(loggedInUserProvider)));

final userServiceProvider = Provider((ref) => UserService(
    analytics: ref.watch(analyticsProvider),
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
  final appState = ref.watch(appStateProvider.notifier);

  var notifier = LoggedInUserStateNotifier(LoggedInUser(),
      client: client.value, appState: appState);

  authState.when(
      data: (user) {
        gqlConfig.isAuthenticated ? notifier.updateUserWithState(user) : {};
      },
      error: (e, trace) => notifier.updateUserWithState(null),
      loading: () => notifier.setIsLoading());

  return notifier;
});

final brandsProvider = Provider<List<BrandModel>>((ref) =>
    ref.watch(loggedInUserProvider.select((value) => value.getUser().brands)));

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

final messagingProvider = Provider<Messaging>((ref) {
  LoginState loginStatus =
      ref.watch(loggedInUserProvider.select((value) => value.status));
  DateTime? lastTokenUpdate = ref.watch(
      loggedInUserProvider.select((value) => value.lastDeviceTokenUpdate));

  Messaging messager = Messaging(
      userService: ref.watch(userServiceProvider),
      lastTokenUpdate: lastTokenUpdate);

  if (loginStatus == LoginState.needToCreateUser ||
      loginStatus == LoginState.isLoggedIn) {
    messager.requestPermissionAndUpdateToken();
  }
  return messager;
});

////////////////////////////////////////
// Analytics providers                //
////////////////////////////////////////

final analyticsProvider = Provider<FirebaseAnalytics>((ref) {
  FirebaseAnalytics instance = FirebaseAnalytics.instance;
  instance.setAnalyticsCollectionEnabled(FlutterAppConfig.isProduction);

  final authState = ref.watch(authStateChangesProvider);
  authState.when(
      data: (user) {
        instance.setUserId(id: user?.uid);
      },
      error: (e, trace) => instance.setUserId(id: null),
      loading: () => {});
  return instance;
});
final analyticsObserverProvider = Provider<FirebaseAnalyticsObserver>((ref) =>
    FirebaseAnalyticsObserver(analytics: (ref.watch(analyticsProvider))));
