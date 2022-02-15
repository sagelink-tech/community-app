import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthState extends ChangeNotifier {
  DateTime? tokenExpiryDate;
  String? token;
  bool get isAuthenticated => token != null && tokenExpiryDate != null;
  bool get isExpired =>
      isAuthenticated && tokenExpiryDate!.isBefore(DateTime.now());

  AuthState({this.token, this.tokenExpiryDate});

  // For Authentication related functions you need an instance of FirebaseAuth
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  //  This getter will be returning a Stream of User object.
  //  It will be used to check if the user is logged in or not.
  Stream<User?> get authStateChange => authInstance.authStateChanges();
  Stream<User?> get idTokenChanges => authInstance.idTokenChanges();

  // Get JWT for signing requests
  Future<void> updateToken({remove = false}) async {
    print("updating token");
    if (remove) {
      print("removing token");
      token = null;
      tokenExpiryDate = null;
      notifyListeners();
      return;
    } else {
      try {
        print("Adding token");
        tokenExpiryDate = DateTime.now().add(const Duration(minutes: 3));
        print(tokenExpiryDate);
        token = await authInstance.currentUser!.getIdToken(true);
        notifyListeners();
        return;
      } catch (e) {
        await updateToken(remove: true);
        return;
      }
    }
  }

  Future<String?> getToken() async {
    if (isAuthenticated && !isExpired) {
      return token;
    } else {
      await updateToken();
      return token;
    }
  }

  //  SigIn the user using Email and Password
  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await authInstance.signInWithEmailAndPassword(
          email: email, password: password);
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
      await authInstance.createUserWithEmailAndPassword(
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
    await authInstance.signOut();
    await updateToken(remove: true);
  }
}
