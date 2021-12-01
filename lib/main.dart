import 'package:community_app/models/app_model.dart';
import 'package:community_app/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:graphql_flutter/graphql_flutter.dart";

import 'providers.dart';
import 'models/logged_in_user.dart';
import 'theme.dart';
import 'views/login_page.dart';

void main() async {
  await initHiveForFlutter();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GraphQL Setup
    final HttpLink link = HttpLink("http://localhost:8000/api/sl/graphql");

    ValueNotifier<GraphQLClient> client = ValueNotifier(
        GraphQLClient(cache: GraphQLCache(store: HiveStore()), link: link));

    // Theme setup
    ThemeType themeType = ThemeType.LightMode;
    AppTheme theme = AppTheme.fromType(themeType);

    // Wrapper around scaffold
    return GraphQLProvider(
      client: client,
      child: MaterialApp(theme: theme.themeData, home: const AppScaffold()),
    );
  }
}

class AppScaffold extends ConsumerWidget {
  const AppScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod setup
    final loggedInUser = ref.watch(loggedInUserProvider);

    if (loggedInUser.status == LoginState.isLoggedIn) {
      return const MainScaffold();
    }

    // Return the current view, based on the currentUser value:
    else {
      return const Scaffold(
        body: LoginPage(),
      );
    }
  }
}
