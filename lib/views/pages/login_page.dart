import 'package:sagelink_communities/models/logged_in_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginPage extends ConsumerWidget {
  final userId1 = "30172a8c-c407-4852-b5b4-d0dedb39bde9";
  final userId2 = "cd329013-5cb6-4bea-882a-8b7a4591dd11";

  const LoginPage({Key? key}) : super(key: key);

  void _handleLogin(
      String userId, GraphQLClient client, LoggedInUserStateNotifier notifier) {
    notifier.loginWithUserId(client, userId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedInUser = ref.watch(loggedInUserProvider);
    final notifier = ref.watch(loggedInUserProvider.notifier);

    return Scaffold(body: GraphQLConsumer(builder: (GraphQLClient client) {
      return Center(
        child: loggedInUser.status == LoginState.isLoggingIn
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    TextButton(
                      child: const Text("Login 1"),
                      onPressed: () =>
                          {_handleLogin(userId1, client, notifier)},
                    ),
                    TextButton(
                      child: const Text("Login 2"),
                      onPressed: () =>
                          {_handleLogin(userId1, client, notifier)},
                    ),
                  ]),
      );
    }));
  }
}
