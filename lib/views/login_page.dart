import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  final userId = "30172a8c-c407-4852-b5b4-d0dedb39bde9";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedInUser = ref.watch(loggedInUserProvider.notifier);

    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text("Login"),
          onPressed: () => {loggedInUser.loginWithUserId(userId)},
        ),
      ),
    );
  }
}
