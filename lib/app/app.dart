import 'package:sagelink_communities/ui/views/scaffold/admin_scaffold.dart';
import 'package:sagelink_communities/ui/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:graphql_flutter/graphql_flutter.dart";
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/ui/theme.dart';
import 'package:sagelink_communities/ui/views/pages/login_page.dart';

class CommunityApp extends StatefulWidget {
  const CommunityApp({required this.appName, required this.apiUrl, Key? key})
      : super(key: key);

  final String appName;
  final String apiUrl;

  @override
  _CommunityAppState createState() => _CommunityAppState();
}

class _CommunityAppState extends State<CommunityApp> {
  @override
  Widget build(BuildContext context) {
    // GraphQL Setup
    final HttpLink link = HttpLink(widget.apiUrl);

    ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
        defaultPolicies: DefaultPolicies(
            watchQuery:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            watchMutation:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            query: Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            mutate:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            subscribe:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all)),
        cache: GraphQLCache(store: HiveStore()),
        link: link));

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
