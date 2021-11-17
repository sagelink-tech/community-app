import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  final userId1 = "30172a8c-c407-4852-b5b4-d0dedb39bde9";
  final userId2 = "cd329013-5cb6-4bea-882a-8b7a4591dd11";
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedInUser = ref.watch(loggedInUserProvider.notifier);

    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                child: const Text("Login 1"),
                onPressed: () => {loggedInUser.loginWithUserId(userId1)},
              ),
              TextButton(
                child: const Text("Login 2"),
                onPressed: () => {loggedInUser.loginWithUserId(userId2)},
              ),
            ]),
      ),
    );
  }
}
