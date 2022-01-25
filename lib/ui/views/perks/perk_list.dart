import 'package:sagelink_communities/ui/components/empty_result.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:sagelink_communities/ui/views/perks/perk_cell.dart';
import 'package:flutter/material.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String? perkId);

class PerkListView extends StatelessWidget {
  final List<PerkModel> perks;
  final OnSelectionCallback onSelection;
  final bool showBrand;

  const PerkListView(this.perks, this.onSelection,
      {this.showBrand = true, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return perks.isNotEmpty
        ? ListView.builder(
            itemCount: perks.length,
            cacheExtent: 20,
            controller: ScrollController(),
            itemBuilder: (context, index) => PerkCell(
                  index,
                  perks[index],
                  onSelection,
                  showBrand: showBrand,
                ))
        : const EmptyResult(text: "Looks like no perks just yet...");
  }
}
