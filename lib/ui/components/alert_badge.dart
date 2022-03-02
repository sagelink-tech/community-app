import 'package:flutter/material.dart';

class AlertBadge extends StatelessWidget {
  final int alertCount;
  final bool showAlertCount;

  const AlertBadge({Key? key, this.alertCount = 0, this.showAlertCount = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
          color: Theme.of(context).errorColor,
          borderRadius: BorderRadius.circular(5)),
    );
  }
}
