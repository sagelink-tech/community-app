/// Modified from: https://stackoverflow.com/questions/49869873/flutter-update-widgets-on-resume

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;
  final AsyncCallback? suspendingCallBack;
  final AsyncCallback? pauseCallback;
  final AsyncCallback? inactiveCallback;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
    this.pauseCallback,
    this.inactiveCallback,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
        if (inactiveCallback != null) {
          await inactiveCallback!();
        }
        break;
      case AppLifecycleState.paused:
        if (pauseCallback != null) {
          await pauseCallback!();
        }
        break;
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack!();
        }
        break;
    }
  }
}
