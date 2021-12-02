import 'package:flutter/material.dart';

class ActivityChip extends StatelessWidget {
  final int activityCount;

  const ActivityChip({Key? key, required this.activityCount}) : super(key: key);

  TextStyle _getTextStyle(context) {
    return (activityCount > 0
        ? TextStyle(inherit: true, color: Theme.of(context).colorScheme.onError)
        : TextStyle(
            inherit: true, color: Theme.of(context).colorScheme.onPrimary));
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
        backgroundColor: activityCount > 0
            ? Theme.of(context).errorColor
            : Theme.of(context).colorScheme.primary,
        labelStyle: _getTextStyle(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        label: Text(activityCount.toString() + " new"));
  }
}
