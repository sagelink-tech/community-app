import 'package:sagelink_communities/views/scaffold/admin_scaffold.dart';
import 'package:sagelink_communities/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:graphql_flutter/graphql_flutter.dart";
import 'providers.dart';
import 'models/logged_in_user.dart';
import 'theme.dart';
import 'views/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await initHiveForFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
