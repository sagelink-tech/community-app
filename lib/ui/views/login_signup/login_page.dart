import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
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

  late final Authentication authState = ref.watch(authProvider);
  late final AppStateStatus appState = ref.watch(appStateProvider);
  late final analytics = ref.watch(analyticsProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      analytics.setCurrentScreen(screenName: "Login View");
      analytics.logScreenView(screenName: "Login View");
    });
  }

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
      CustomWidgets.buildSnackBar(
          context, "Enter email and password", SLSnackBarType.error);
    } else {
      analytics.logEvent(name: "login_with_email");
      await authState.signInWithEmailAndPassword(email!, password!, context);
    }
  }

  void _handleSignup(BuildContext context) async {
    analytics.logEvent(name: "signup_with_email");

    if (!appState.hasSignedIn) {
      bool? result = await _showAlertDialog();
      if (result == null || !result) {
        return;
      }
    }
    if (email == null || password == null) {
      CustomWidgets.buildSnackBar(
          context, "Enter email and password", SLSnackBarType.error);
    } else {
      await authState.signUpWithEmailAndPassword(email!, password!, context);
    }
  }

  void _handleGoogleSignIn(BuildContext context) async {
    analytics.logEvent(name: "signin_with_google");

    if (!appState.hasSignedIn) {
      bool? result = await _showAlertDialog();
      if (result == null || !result) {
        return;
      }
    }
    await authState.signInWithGoogle(context);
  }

  void _handleAppleSignIn(BuildContext context) async {
    analytics.logEvent(name: "signin_with_apple");
    if (!appState.hasSignedIn) {
      bool? result = await _showAlertDialog();
      if (result == null || !result) {
        return;
      }
    }
    await authState.signInWithApple(context);
  }

  Future<bool?> _showAlertDialog() async {
    if (kIsWeb) {
      return true;
    }
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
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => FractionallySizedBox(
            heightFactor: 0.85,
            child: FeedbackForm(
                onSubmit: () => _dismissFeedbackForm(context),
                onCancel: () => _dismissFeedbackForm(context))));
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
              : CustomWidgets.buildSnackBar(
                  context,
                  "Enter your email into the email field to have a reset link sent to you.",
                  SLSnackBarType.error)));

  Widget buildTermsText() => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "By continuing, you agree to Sagelink's ",
              style:
                  Theme.of(context).textTheme.caption!.copyWith(fontSize: 12.0),
            ),
            TextSpan(
              text: 'Terms of Service',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 12.0),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch('https://sage.link/terms');
                },
            ),
            TextSpan(
              text: " and acknowledge that you've read the ",
              style:
                  Theme.of(context).textTheme.caption!.copyWith(fontSize: 12.0),
            ),
            TextSpan(
              text: 'Privacy Policy.',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 12.0),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch('https://sage.link/privacy');
                },
            ),
          ],
        ),
      );

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
        const ListSpacer(height: 10),
        SignInButton(Buttons.Apple,
            onPressed: () => {
                  _handleAppleSignIn(context),
                }),
        const ListSpacer(height: 20),
        buildTermsText()
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        body: GraphQLConsumer(builder: (GraphQLClient client) {
          return Center(
              child: Container(
                  margin:
                      kIsWeb ? const EdgeInsets.symmetric(vertical: 10) : null,
                  decoration: kIsWeb
                      ? BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(5),
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                        )
                      : null,
                  constraints:
                      const BoxConstraints(maxWidth: 500, minWidth: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Center(
                    child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const Image(
                              image: AssetImage('assets/splash.png'),
                              fit: BoxFit.scaleDown,
                              height: 40),
                          ..._loginWidgets()
                        ]),
                  )));
        }));
  }
}
