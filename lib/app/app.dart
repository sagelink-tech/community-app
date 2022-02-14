import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/views/login_signup/tutorial_pages.dart';
import 'package:sagelink_communities/ui/views/scaffold/admin_scaffold.dart';
import 'package:sagelink_communities/ui/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:graphql_flutter/graphql_flutter.dart";
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/ui/theme.dart';
import 'package:sagelink_communities/ui/views/login_signup/login_page.dart';

class CommunityApp extends ConsumerStatefulWidget {
  const CommunityApp({required this.appName, Key? key}) : super(key: key);

  final String appName;

  @override
  _CommunityAppState createState() => _CommunityAppState();
}

class _CommunityAppState extends ConsumerState<CommunityApp> {
  late final ValueNotifier<GraphQLClient> client = ref.watch(gqlClientProvider);
  late final AppStateStatus appState = ref.watch(appStateProvider);

  ThemeData _theme() {
    // Theme setup
    ThemeType themeType =
        appState.isDarkModeEnabled ? ThemeType.darkMode : ThemeType.lightMode;
    return AppTheme.fromType(themeType).themeData;
  }

  @override
  Widget build(BuildContext context) {
    // GraphQL Setup

    // Wrapper around scaffold
    return GraphQLProvider(
        client: client,
        child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild!.unfocus();
              }
            },
            child: MaterialApp(theme: _theme(), home: BaseApp())));
  }
}

class BaseApp extends ConsumerWidget {
  Widget _home(LoggedInUser loggedInUser, AppStateStatus appState) {
    switch (loggedInUser.status) {
      case LoginState.isLoggedIn:
        return (appState.isViewingAdminSite && loggedInUser.isAdmin)
            ? const AdminScaffold()
            : const MainScaffold();
      case LoginState.isLoggingIn:
        return const Scaffold(body: Loading());
      case LoginState.isLoggedOut:
        return const Scaffold(
          body: LoginPage(),
        );
      case LoginState.needToCreateUser:
        return const Scaffold(
            body: Center(child: Text("Need to get user info")));
    }
  }

  Widget _splash(BuildContext bc) {
    return Scaffold(
        body: Center(
            child: Text("SAGELINK", style: Theme.of(bc).textTheme.headline6!)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoggedInUser loggedInUser = ref.watch(loggedInUserProvider);
    final AppState appState = ref.watch(appStateProvider.notifier);
    final AppStateStatus appStateStatus = ref.watch(appStateProvider);

    if (!appStateStatus.tutorialComplete) {
      return TutorialPages(onComplete: () => appState.completedTutorial());
    } else {
      return _home(loggedInUser, appStateStatus);
    }
  }
}
