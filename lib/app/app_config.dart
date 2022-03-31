import 'dart:async';
//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/app/firebase_options.dart';
import 'app.dart';

enum AppEnvironment { dev, demo, prod }

class FlutterAppConfig {
  static const appName =
      String.fromEnvironment('SL_APP_NAME', defaultValue: 'communityApp');
  static const appSuffix = String.fromEnvironment('SL_APP_SUFFIX');
  static const usesHttps =
      bool.fromEnvironment('SL_USES_HTTPS', defaultValue: false);
  static const apiBaseUrl =
      String.fromEnvironment('SL_API_URL', defaultValue: 'localhost/graphql');
  static const initializeCrashlytics =
      bool.fromEnvironment('SL_CRASHLYTICS_FLAG', defaultValue: true);
  static const isProduction =
      bool.fromEnvironment('SL_PRODUCTION_FLAG', defaultValue: true);
  static const useEmulator =
      bool.fromEnvironment('SL_EMULATOR_FLAG', defaultValue: false);

  static get environment {
    return isProduction
        ? AppEnvironment.prod
        : appSuffix.contains('demo')
            ? AppEnvironment.demo
            : AppEnvironment.dev;
  }

  // Future startCrashlytics() async {
  //   if (this.initializeCrashlytics) {
  //     Crashlytics.instance.enableInDevMode = enableCrashlyiticsInDevMode;
  //     FlutterError.onError = (FlutterErrorDetails details) {
  //       Crashlytics.instance.onError(details);
  //     };
  //   }
  // }

  static String apiUrl() => (usesHttps ? "https://" : "http://") + apiBaseUrl;

  static String host() => apiBaseUrl.split('/')[0];

  Widget createApp() {
    return const ProviderScope(
        child: CommunityApp(
      appName: appName,
    ));
  }

  Future run() async {
    // await startCrashlytics();
    //final _state = await loadState();
    await initHiveForFlutter();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      //name: isProduction ? "prod" : "dev",
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (FlutterAppConfig.useEmulator) {
      await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    }
    runApp(createApp());
  }
}
