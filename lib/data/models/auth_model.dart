import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class Authentication {
  // For Authentication related functions you need an instance of FirebaseAuth
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  //  This getter will be returning a Stream of User object.
  //  It will be used to check if the user is logged in or not.
  Stream<User?> get authStateChange => authInstance.authStateChanges();
  Stream<User?> get idTokenChanges => authInstance.idTokenChanges();
  Stream<User?> get userChanges => authInstance.userChanges();

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
      return null;
    }
  }

  // Send forgot password email
  Future<void> sendForgotPasswordEmail(
      String email, BuildContext context) async {
    try {
      await authInstance.sendPasswordResetEmail(email: email);
      CustomWidgets.buildSnackBar(
          context, "Check your inbox for a reset link!", SLSnackBarType.error);
    } on FirebaseException catch (e) {
      CustomWidgets.buildSnackBar(
          context, "Error sending password reset: $e", SLSnackBarType.error);
    }
  }

  //  SigIn the user using Email and Password
  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await authInstance.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      CustomWidgets.buildSnackBar(
          context, "Error signing in: $e", SLSnackBarType.error);
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
      CustomWidgets.buildSnackBar(
          context,
          e.message ?? "Error creating this account. Please try again.",
          SLSnackBarType.error);
    }
  }

  //  SignIn the user Google
  Future<void> signInWithGoogle(BuildContext context) async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Once signed in, return the UserCredential
      try {
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } on FirebaseAuthException catch (e) {
        CustomWidgets.buildSnackBar(
            context,
            e.message ?? "Error with google sign in: ${e.message}",
            SLSnackBarType.error);
      }
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        await authInstance.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        CustomWidgets.buildSnackBar(
            context,
            e.message ?? "Error with google sign in: ${e.message}",
            SLSnackBarType.error);
      }
    }
  }

  // SignIn with user Apple
  Future<void> signInWithApple(BuildContext context) async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.

    if (kIsWeb) {
      try {
        final provider = OAuthProvider("apple.com")
          ..addScope('email')
          ..addScope('name');

        // Sign in the user with Firebase.
        await FirebaseAuth.instance.signInWithPopup(provider);
      } on FirebaseAuthException catch (e) {
        CustomWidgets.buildSnackBar(
            context,
            e.message ?? "Error with apple sign in: ${e.message}",
            SLSnackBarType.error);
      } catch (e) {
        return;
      }
    } else {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      try {
        // Request credential for the currently signed in Apple account.
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        final displayName =
            "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}";

        // Create an `OAuthCredential` from the credential returned by Apple.
        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        UserCredential cred =
            await authInstance.signInWithCredential(oauthCredential);
        if (displayName != " ") {
          await cred.user?.updateDisplayName(displayName);
        }
      } on FirebaseAuthException catch (e) {
        CustomWidgets.buildSnackBar(
            context,
            e.message ?? "Error with apple sign in: ${e.message}",
            SLSnackBarType.error);
      } catch (e) {
        return;
      }
    }
  }

  //  SignOut the current user
  Future<void> signOut() async {
    await authInstance.signOut();
  }

  Future<void> reloadUser() async {
    try {
      //authInstance.currentUser?.reload();
    } catch (e) {
      print(e);
      return;
    }
  }
}
