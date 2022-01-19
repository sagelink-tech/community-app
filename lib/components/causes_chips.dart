import 'package:sagelink_communities/models/cause_model.dart';
import 'package:flutter/material.dart';

typedef OnCauseDeletionCallback = void Function(CauseModel? cause);

class CausesChips extends StatelessWidget {
  final List<CauseModel> causes;
  final bool allowDeletion;
  final OnCauseDeletionCallback? onCauseDeleted;

  const CausesChips(
      {Key? key,
      required this.causes,
      this.allowDeletion = false,
      this.onCauseDeleted})
      : super(key: key);

  Chip _buildChip(CauseModel cause) {
    return Chip(
        label: Text(cause.title),
        onDeleted: !allowDeletion
            ? null
            : () => {
                  if (onCauseDeleted != null) {onCauseDeleted!(cause)}
                });
  }

  @override
  Widget build(BuildContext context) {
    if (causes.isEmpty) {
      return const SizedBox(height: 30);
    }
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: causes.map((c) => _buildChip(c)).toList(),
    );
  }
}
