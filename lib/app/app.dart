import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/views/scaffold/admin_scaffold.dart';
import 'package:sagelink_communities/ui/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:graphql_flutter/graphql_flutter.dart";
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/ui/theme.dart';
import 'package:sagelink_communities/ui/views/pages/login_page.dart';

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

    ThemeData _theme() {
      // Theme setup
      ThemeType themeType =
          appState.isDarkModeEnabled ? ThemeType.darkMode : ThemeType.lightMode;
      return AppTheme.fromType(themeType).themeData;
    }

    Widget _home() {
      if (loggedInUser.status == LoginState.isLoggedIn) {
        return (appState.viewingAdminSite && loggedInUser.isAdmin)
            ? const AdminScaffold()
            : const MainScaffold();
      }
      if ([LoginState.isLoggingIn, LoginState.needToCreateUser]
          .contains(loggedInUser.status)) {
        return const Scaffold(body: Loading());
      }

      // Return the current view, based on the currentUser value:
      else {
        return const Scaffold(
          body: LoginPage(),
        );
      }
    }

    return MaterialApp(theme: _theme(), home: _home());
  }
}
