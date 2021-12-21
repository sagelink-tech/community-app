import 'package:sagelink_communities/components/empty_result.dart';
import 'package:sagelink_communities/models/perk_model.dart';
import 'package:sagelink_communities/views/perks/perk_cell.dart';
import 'package:flutter/material.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String? perkId);

class PerkListView extends StatelessWidget {
  final List<PerkModel> perks;
  final OnSelectionCallback onSelection;

  const PerkListView(this.perks, this.onSelection, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return perks.isNotEmpty
        ? ListView.builder(
            itemCount: perks.length,
            cacheExtent: 20,
            controller: ScrollController(),
            itemBuilder: (context, index) =>
                PerkCell(index, perks[index], onSelection))
        : const EmptyResult(text: "Looks like no perks just yet...");
  }
}
