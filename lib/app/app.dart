import 'package:flutter/foundation.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/components/splash_screen.dart';
import 'package:sagelink_communities/ui/views/login_signup/login_page.dart';
import 'package:sagelink_communities/ui/views/login_signup/tutorial_pages.dart';
import 'package:sagelink_communities/ui/views/login_signup/user_creation.dart';
import 'package:sagelink_communities/ui/views/scaffold/admin_scaffold.dart';
import 'package:sagelink_communities/ui/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:graphql_flutter/graphql_flutter.dart";
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/ui/theme.dart';

class CommunityApp extends ConsumerStatefulWidget {
  const CommunityApp({required this.appName, Key? key}) : super(key: key);

  final String appName;

  @override
  _CommunityAppState createState() => _CommunityAppState();
}

class _CommunityAppState extends ConsumerState<CommunityApp> {
  @override
  Widget build(BuildContext context) {
    // GraphQL Setup
    ValueNotifier<GraphQLClient> client = (ref).watch(gqlClientProvider);

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
          child: const BaseApp(),
        ));
  }
}

class BaseApp extends ConsumerWidget {
  const BaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod setup
    final loggedInUser = ref.watch(loggedInUserProvider);
    final appState = ref.watch(appStateProvider);
    final appStateNotifier = ref.watch(appStateProvider.notifier);

    ThemeData _theme() {
      // Theme setup
      ThemeType themeType =
          appState.isDarkModeEnabled ? ThemeType.darkMode : ThemeType.lightMode;
      return AppTheme.fromType(themeType).themeData;
    }

    Widget _home() {
      if (!appState.tutorialComplete) {
        return TutorialPages(onComplete: appStateNotifier.completedTutorial);
      }
      switch (loggedInUser.status) {
        case LoginState.isLoggedIn:
          return (appState.isViewingAdminSite && loggedInUser.isAdmin)
              ? const AdminScaffold()
              : const MainScaffold();
        case LoginState.isLoggedOut:
          return const Scaffold(body: LoginPage());
        case LoginState.isLoggingIn:
          return const Scaffold(body: Loading());
        case LoginState.needToCreateUser:
          return const UserCreationPage();
      }
    }

    return MaterialApp(theme: _theme(), home: _home());
  }
}
