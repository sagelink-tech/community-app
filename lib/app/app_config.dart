import 'dart:async';
//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/firebase_options.dart';
import 'app.dart';

class FlutterAppConfig {
  FlutterAppConfig();

  static const appName =
      String.fromEnvironment('SL_APP_NAME', defaultValue: 'communityApp');
  static const appId = String.fromEnvironment('SL_APP_SUFFIX');
  static const usesHttps =
      bool.fromEnvironment('SL_USES_HTTPS', defaultValue: false);
  static const apiBaseUrl =
      String.fromEnvironment('SL_API_URL', defaultValue: 'localhost/graphql');
  static const initializeCrashlytics =
      bool.fromEnvironment('SL_CRASHLYTICS_FLAG', defaultValue: true);
  static const isDevelopment =
      bool.fromEnvironment('SL_DEVELOPMENT_FLAG', defaultValue: true);

  // Future startCrashlytics() async {
  //   if (this.initializeCrashlytics) {
  //     Crashlytics.instance.enableInDevMode = enableCrashlyiticsInDevMode;
  //     FlutterError.onError = (FlutterErrorDetails details) {
  //       Crashlytics.instance.onError(details);
  //     };
  //   }
  // }

  String apiUrl() => (usesHttps ? "https://" : "http://") + apiBaseUrl;

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
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(createApp());
  }
}
