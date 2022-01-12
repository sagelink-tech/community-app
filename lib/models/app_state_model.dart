import 'package:flutter/material.dart';

enum DeviceState {
  mobile,
  web,
}

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

  // Screen sizes
  DeviceState deviceState = DeviceState.mobile;
  void updateDeviceState(Size screenSize) {
    deviceState =
        screenSize.shortestSide <= 550 ? DeviceState.mobile : DeviceState.web;
    notifyListeners();
  }
}
