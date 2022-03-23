import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateStatus {
  bool tutorialComplete;
  bool isDarkModeEnabled;
  bool isViewingAdminSite;
  bool verifiedProfile;
  bool loadingPrefs;
  bool hasSignedIn;

  AppStateStatus(
      {this.tutorialComplete = false,
      this.isDarkModeEnabled = false,
      this.verifiedProfile = false,
      this.hasSignedIn = false,
      this.isViewingAdminSite = kIsWeb,
      this.loadingPrefs = false});
}

class AppState extends StateNotifier<AppStateStatus> {
  static const String _tutorialFlagKey = "COMPLETED_TUTORIAL";
  static const String _isDarkModeKey = "DARK_MODE";
  static const String _verifiedProfileKey = "VERIFIED_PROFILE";
  static const String _hasSignedInKey = "SIGNED_IN_BEFORE";

  AppState(this.prefs) : super(AppState.statusWithPrefs(prefs));

  static AppStateStatus statusWithPrefs(SharedPreferences? prefs,
      {bool isViewingAdminSite = kIsWeb}) {
    return AppStateStatus(
        loadingPrefs: prefs == null,
        tutorialComplete: prefs?.getBool(_tutorialFlagKey) ?? false,
        isDarkModeEnabled: prefs?.getBool(_isDarkModeKey) ?? false,
        verifiedProfile: prefs?.getBool(_verifiedProfileKey) ?? false,
        hasSignedIn: prefs?.getBool(_hasSignedInKey) ?? false,
        isViewingAdminSite: isViewingAdminSite);
  }

  final SharedPreferences? prefs;

  // Turn off tutorials
  void completedTutorial() {
    prefs?.setBool(_tutorialFlagKey, true);
    state = AppState.statusWithPrefs(prefs,
        isViewingAdminSite: state.isViewingAdminSite);
  }

  // Verified profile
  void didCompleteProfile() {
    prefs?.setBool(_verifiedProfileKey, true);
    state = AppState.statusWithPrefs(prefs,
        isViewingAdminSite: state.isViewingAdminSite);
  }

  // Has signed in before
  void didSignIn() {
    prefs?.setBool(_hasSignedInKey, true);
    state = AppState.statusWithPrefs(prefs,
        isViewingAdminSite: state.isViewingAdminSite);
  }

  // Set theme state
  void setLightTheme() {
    prefs?.setBool(_isDarkModeKey, false);
    state = AppState.statusWithPrefs(prefs,
        isViewingAdminSite: state.isViewingAdminSite);
  }

  void setDarkTheme() {
    prefs?.setBool(_isDarkModeKey, true);
    state = AppState.statusWithPrefs(prefs,
        isViewingAdminSite: state.isViewingAdminSite);
  }

  void setViewingAdminSite(bool viewAdminSite) {
    state.isViewingAdminSite = viewAdminSite;
    state = AppState.statusWithPrefs(prefs, isViewingAdminSite: viewAdminSite);
  }
}
