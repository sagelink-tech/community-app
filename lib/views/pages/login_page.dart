import 'package:flutter/material.dart';
import 'package:sagelink_communities/models/logged_in_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String? email;

  final userId1 = "d01dee82-e65b-43b1-bc50-3a50b7c4fe33";
  final userId2 = "cd329013-5cb6-4bea-882a-8b7a4591dd11";

  void _handleLogin(GraphQLClient client, LoggedInUserStateNotifier notifier,
      BuildContext context) {
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Enter Email"),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } else {
      notifier.loginWithEmail(client, email!, context);
    }
  }

  Widget buildEmailForm({bool enabled = true}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Email',
          border: const OutlineInputBorder(),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).errorColor)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          errorStyle: TextStyle(color: Theme.of(context).errorColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an email';
          } else {
            return null;
          }
        },
        maxLength: 50,
        onChanged: (value) => setState(() => email = value),
        enabled: enabled,
      ));

  @override
  Widget build(BuildContext context) {
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
                    buildEmailForm(),
                    ElevatedButton(
                        onPressed: () =>
                            _handleLogin(client, notifier, context),
                        child: const Text("Submit")),
                  ]),
      );
    }));
  }
}
