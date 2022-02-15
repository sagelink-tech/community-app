import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool isLoggingIn = false;
  late final AuthState authState = ref.watch(authProvider);

  void _handleLogin(BuildContext context) async {
    if (email == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Enter email and password"),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } else {
      setState(() {
        isLoggingIn = true;
      });
      await authState.signInWithEmailAndPassword(email!, password!, context);
      setState(() {
        isLoggingIn = false;
      });
    }
  }

  void _handleSignup(BuildContext context) async {
    if (email == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Enter email and password"),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } else {
      setState(() {
        isLoggingIn = true;
      });
      await authState.signUpWithEmailAndPassword(email!, password!, context);
      setState(() {
        isLoggingIn = false;
      });
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
        onChanged: (value) => setState(() => email = value),
        enabled: enabled,
      ));
  Widget buildPasswordForm({bool enabled = true}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: "Password",
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => password = value),
        enabled: enabled,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GraphQLConsumer(builder: (GraphQLClient client) {
      return Center(
        child: isLoggingIn
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    buildEmailForm(),
                    buildPasswordForm(),
                    ElevatedButton(
                        onPressed: () => {
                              _handleLogin(context),
                              setState(() {
                                isLoggingIn = true;
                              })
                            },
                        child: const Text("Login")),
                    ElevatedButton(
                        onPressed: () => {
                              _handleSignup(context),
                              setState(() {
                                isLoggingIn = true;
                              })
                            },
                        child: const Text("Signup")),
                  ]),
      );
    }));
  }
}
