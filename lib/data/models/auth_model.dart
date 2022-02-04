import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  // For Authentication related functions you need an instance of FirebaseAuth
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  //  This getter will be returning a Stream of User object.
  //  It will be used to check if the user is logged in or not.
  Stream<User?> get authStateChange => authInstance.authStateChanges();

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
  Future<String?> getJWT() async {
    try {
      String token = await authInstance.currentUser!.getIdToken(true);
      return token;
    } catch (e) {
      print(e);
      return null;
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
      authInstance.createUserWithEmailAndPassword(
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
        // print('Email already in use.');
      } else if (e == 'weak-password') {
        // print('Error: "Password is too weak');
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
