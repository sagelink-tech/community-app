import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authentication extends ChangeNotifier {
  // For Authentication related functions you need an instance of FirebaseAuth
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  DateTime? tokenExpiryDate;
  String? token;

  bool get isAuthenticated => token != null && tokenExpiryDate != null;

  Authentication() {
    authStateChange.listen((user) {
      if (user != null) {
        updateToken();
      } else {
        updateToken(remove: true);
      }
    });
  }

  //  This getter will be returning a Stream of User object.
  //  It will be used to check if the user is logged in or not.
  Stream<User?> get authStateChange => authInstance.authStateChanges();
  Stream<User?> get idTokenChanges => authInstance.idTokenChanges();

  // Now This Class Contains 3 Functions currently
  // 1. signInWithGoogle
  // 2. signOut
  // 3. signInwithEmailAndPassword

  //  All these functions are async because this involves a future.
  //  if async keyword is not used, it will throw an error.
  //  to know more about futures, check out the documentation.
  //  https://dart.dev/codelabs/async-await
  //  Read this to know more about futures.
  //  Trust me it will really clear all your concepts about futures

  // Get JWT for signing requests
  Future<void> updateToken({remove = false}) async {
    print("updating token");
    if (remove) {
      token = null;
      tokenExpiryDate = null;
      notifyListeners();
    } else {
      try {
        tokenExpiryDate = DateTime.now().add(const Duration(minutes: 3));
        String _token = await authInstance.currentUser!.getIdToken(true);
        token = _token;
        notifyListeners();
      } catch (e) {
        token = null;
        tokenExpiryDate = null;
        notifyListeners();
      }
    }
  }

  //  SigIn the user using Email and Password
  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await authInstance.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error signing in: $e"),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
  }

  // SignUp the user using Email and Password
  Future<void> signUpWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: const Text('Error Occured'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("OK"))
                  ]));
    } catch (e) {
      if (e == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("The email you entered is already in user"),
          backgroundColor: Theme.of(context).errorColor,
        ));
      } else if (e == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Please enter a more secure password"),
          backgroundColor: Theme.of(context).errorColor,
        ));
      } else {
        // print(e);
      }
    }
  }

  //  SignIn the user Google
  // Future<void> signInWithGoogle(BuildContext context) async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser!.authentication;

  //   // Create a new credential
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   try {
  //     await _auth.signInWithCredential(credential);
  //   } on FirebaseAuthException catch (e) {
  //     await showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         title: const Text('Error Occured'),
  //         content: Text(e.toString()),
  //         actions: [
  //           TextButton(
  //               onPressed: () {
  //                 Navigator.of(ctx).pop();
  //               },
  //               child: const Text("OK"))
  //         ],
  //       ),
  //     );
  //   }
  // }

  //  SignOut the current user
  Future<void> signOut() async {
    await authInstance.signOut();
  }
}
