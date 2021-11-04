import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list_row.dart';
import 'package:flutter/material.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String brandId);

class BrandListView extends StatelessWidget {
  final List<BrandModel> brands;
  final OnSelectionCallback onSelection;

  const BrandListView(this.brands, this.onSelection, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return ListView.builder(
        itemCount: brands.length,
        cacheExtent: 20,
        controller: ScrollController(),
        itemBuilder: (context, index) =>
            BrandListRow(index, brands[index], onSelection));
  }
}
