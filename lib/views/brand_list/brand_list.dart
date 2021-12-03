import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list_cell.dart';
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
    // Check for device size
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    bool showSmallScreenView = queryData.size.width < 600;
    // Render list of widgets

    return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: showSmallScreenView ? 2 : 4, mainAxisExtent: 250),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          return BrandListCell(index, brands[index], onSelection);
        });
  }
}
