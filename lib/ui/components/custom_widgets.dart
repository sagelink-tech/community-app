import 'package:flutter/material.dart';

enum SLSnackBarType { error, success, neutral }

class CustomWidgets {
  CustomWidgets._();
  static buildSnackBar(
      BuildContext context, String message, SLSnackBarType type) {
    Color backgroundColor(BuildContext context) {
      switch (type) {
        case SLSnackBarType.error:
          return Theme.of(context).errorColor;
        case SLSnackBarType.success:
          return const Color(0xFF5ACCAA);
        case SLSnackBarType.neutral:
          return Theme.of(context).primaryColor;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: backgroundColor(context)),
    );
  }
}
