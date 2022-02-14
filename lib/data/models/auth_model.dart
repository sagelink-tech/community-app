import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  DateTime? tokenExpiryDate;
  String? token;
  bool get isAuthenticated => token != null && tokenExpiryDate != null;
  bool get isExpired =>
      isAuthenticated && tokenExpiryDate!.isBefore(DateTime.now());

  // For Authentication related functions you need an instance of FirebaseAuth
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  //  This getter will be returning a Stream of User object.
  //  It will be used to check if the user is logged in or not.
  Stream<User?> get authStateChange => authInstance.authStateChanges();
  Stream<User?> get idTokenChanges => authInstance.idTokenChanges();

  AuthState({this.token, this.tokenExpiryDate});
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(AuthState state) : super(state);

  static final provider =
      StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
    return AuthStateNotifier(AuthState());
  });

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
      print("removing token");
      state = AuthState();
      return;
    } else {
      try {
        print("Adding token");
        DateTime expiryDate = DateTime.now().add(const Duration(minutes: 3));
        String token = await state.authInstance.currentUser!.getIdToken(true);
        state = AuthState(token: token, tokenExpiryDate: expiryDate);
        return;
      } catch (e) {
        await updateToken(remove: true);
        return;
      }
    }
  }

  //  SigIn the user using Email and Password
  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await state.authInstance
          .signInWithEmailAndPassword(email: email, password: password);
      await updateToken();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error signing in: $e"),
        backgroundColor: Theme.of(context).errorColor,
      ));
      await updateToken(remove: true);
    }
  }

  // SignUp the user using Email and Password
  Future<void> signUpWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await state.authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await updateToken();
    } catch (e) {
      await updateToken(remove: true);
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
    await state.authInstance.signOut();
    await updateToken(remove: true);
  }
}
