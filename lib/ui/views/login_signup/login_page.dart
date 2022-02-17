import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/components/feedback_form.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:url_launcher/url_launcher.dart';

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

  late final Authentication authState = ref.watch(authProvider);
  late final AppStateStatus appState = ref.watch(appStateProvider);

  bool get isValid =>
      email != null &&
      email!.isNotEmpty &&
      password != null &&
      password!.isNotEmpty;

  void _handleLogin(BuildContext context) async {
    if (!appState.hasSignedIn) {
      bool? result = await _showAlertDialog();
      if (result == null || !result) {
        return;
      }
    }
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
    if (!appState.hasSignedIn) {
      bool? result = await _showAlertDialog();
      if (result == null || !result) {
        return;
      }
    }
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

  void _handleGoogleSignIn(BuildContext context) async {
    if (!appState.hasSignedIn) {
      bool? result = await _showAlertDialog();
      if (result == null || !result) {
        return;
      }
    }
    setState(() {
      isLoggingIn = true;
    });
    await authState.signInWithGoogle(context);
    setState(() {
      isLoggingIn = false;
    });
  }

  void _handleAppleSignIn(BuildContext context) async {
    if (!appState.hasSignedIn) {
      bool? result = await _showAlertDialog();
      if (result == null || !result) {
        return;
      }
    }
    setState(() {
      isLoggingIn = true;
    });
    await authState.signInWithApple(context);
    setState(() {
      isLoggingIn = false;
    });
  }

  Future<bool?> _showAlertDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Did you get an invite to a brand community?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Text(
                  'Before you create an account, make sure that you have an invite code from a brand to join their community!'),
              Text(
                  "If you don't have one, we'd still love to hear from you! Share what brands you like and what brought you here!"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('I have an invite code!'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('No invite code yet'),
              onPressed: () {
                Navigator.of(context).pop(false);
                _showFeedbackForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _dismissFeedbackForm(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showFeedbackForm() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => FeedbackForm(
            onSubmit: () => _dismissFeedbackForm(context),
            onCancel: () => _dismissFeedbackForm(context)));
  }

  Widget buildEmailForm({bool enabled = true}) => TextFormField(
        key: const Key("email_key"),
        initialValue: email,
        decoration: InputDecoration(
          labelText: 'Email',
          border: const OutlineInputBorder(),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).errorColor)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          errorStyle: TextStyle(color: Theme.of(context).errorColor),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an email';
          } else {
            return null;
          }
        },
        onChanged: (value) => setState(() => email = value),
        enabled: enabled,
      );

  Widget buildPasswordForm({bool enabled = true}) => TextFormField(
        key: const Key("password_key"),
        initialValue: password,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: "Password",
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => password = value),
        enabled: enabled,
      );

  Widget buildPasswordResetLink() => Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
          child: Text('Forgot password',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(decoration: TextDecoration.underline)),
          onTap: () => email != null
              ? authState.sendForgotPasswordEmail(email!, context)
              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                      "Enter your email into the email field to have a reset link sent to you."),
                  backgroundColor: Theme.of(context).errorColor,
                ))));

  List<Widget> _loginWidgets() => [
        const ListSpacer(height: 50),
        buildEmailForm(),
        const ListSpacer(height: 20),
        buildPasswordForm(),
        const ListSpacer(height: 20),
        buildPasswordResetLink(),
        const ListSpacer(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                onPrimary: Theme.of(context).colorScheme.onError,
                minimumSize: const Size.fromHeight(48)),
            onPressed: isValid ? () => _handleLogin(context) : null,
            child: const Text("Login")),
        const ListSpacer(height: 20),
        OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: 1.0,
                    color: isValid
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).dividerColor),
                primary: Theme.of(context).colorScheme.secondary,
                minimumSize: const Size.fromHeight(48)),
            onPressed: isValid ? () => _handleSignup(context) : null,
            child: const Text("Signup")),
        const ListSpacer(height: 20),
        const Divider(),
        const ListSpacer(height: 20),
        SignInButton(Buttons.Google,
            padding: EdgeInsets.zero,
            elevation: 1,
            onPressed: () => _handleGoogleSignIn(context)),
        SignInButton(Buttons.Apple,
            onPressed: () => {
                  _handleAppleSignIn(context),
                }),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GraphQLConsumer(builder: (GraphQLClient client) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: isLoggingIn
                ? const CircularProgressIndicator()
                : ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                        const Image(
                          image: AssetImage('assets/splash.png'),
                          fit: BoxFit.fitWidth,
                          width: 150,
                        ),
                        ..._loginWidgets()
                      ]),
          ));
    }));
  }
}
