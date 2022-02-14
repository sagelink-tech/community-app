import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateStatus {
  bool tutorialComplete;
  bool isDarkModeEnabled;
  bool isViewingAdminSite;

  AppStateStatus(
      {this.tutorialComplete = false,
      this.isDarkModeEnabled = false,
      this.isViewingAdminSite = kIsWeb});
}

class AppState extends StateNotifier<AppStateStatus> {
  static const String _tutorialFlagKey = "COMPLETED_TUTORIAL";
  static const String _isDarkModeKey = "DARK_MODE";
  late AppStateStatus status;

  AppState(this.prefs) : super(AppState.statusWithPrefs(prefs));

  static AppStateStatus statusWithPrefs(SharedPreferences? prefs) {
    return AppStateStatus(
        tutorialComplete: prefs?.getBool(_tutorialFlagKey) ?? false,
        isDarkModeEnabled: prefs?.getBool(_isDarkModeKey) ?? false,
        isViewingAdminSite: kIsWeb);
  }

  final SharedPreferences? prefs;

  // Turn off tutorials
  void completedTutorial() {
    prefs?.setBool(_tutorialFlagKey, true);
    state = AppState.statusWithPrefs(prefs);
  }

  // Set theme state
  void setLightTheme() {
    prefs?.setBool(_isDarkModeKey, false);
    state = AppState.statusWithPrefs(prefs);
  }

  void setDarkTheme() {
    prefs?.setBool(_isDarkModeKey, true);
    state = AppState.statusWithPrefs(prefs);
  }

  void setViewingAdminSite(bool viewAdminSite) {
    state.isViewingAdminSite = viewAdminSite;
    state = AppState.statusWithPrefs(prefs);
  }
}
