import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // Theme state
  var isDarkModeEnabled = false;
  void setLightTheme() {
    isDarkModeEnabled = false;
    notifyListeners();
  }

  void setDarkTheme() {
    isDarkModeEnabled = true;
    notifyListeners();
  }

  // Admin state
  var viewingAdminSite = false;

  void setViewingAdminSite(bool viewAdminSite) {
    viewingAdminSite = viewAdminSite;
    notifyListeners();
  }
}
