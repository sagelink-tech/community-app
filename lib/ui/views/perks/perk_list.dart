import 'dart:math';

import 'package:flutter/foundation.dart';
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

  Widget _buildList(BuildContext context, bool showGrid) {
    double minWidth = 450;
    double spacing = 20;
    int colCount = max(
        1,
        min(MediaQuery.of(context).size.width ~/ (minWidth + spacing).floor(),
            3));

    if (!showGrid || colCount == 1) {
      return ListView.separated(
          itemCount: perks.length,
          cacheExtent: 20,
          controller: ScrollController(),
          separatorBuilder: (context, index) => Divider(
                thickness: 8,
                color: Colors.grey.shade300,
              ),
          itemBuilder: (context, index) => PerkCell(
                index,
                perks[index],
                onSelection,
                showBrand: showBrand,
              ));
    } else {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing),
          itemCount: perks.length,
          itemBuilder: (context, index) => Card(
              semanticContainer: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: PerkCell(
                index,
                perks[index],
                onSelection,
                showBrand: showBrand,
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return perks.isNotEmpty
        ? _buildList(context, kIsWeb)
        : const EmptyResult(text: "Looks like no perks just yet...");
  }
}
