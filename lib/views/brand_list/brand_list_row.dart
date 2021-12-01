import 'package:flutter/material.dart';

import 'package:community_app/models/brand_model.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String brandId);

class BrandListRow extends StatelessWidget {
  final int itemNo;
  final BrandModel brand;
  final OnSelectionCallback onSelection;

  const BrandListRow(this.itemNo, this.brand, this.onSelection, {Key? key})
      : super(key: key);

  void _handleSelection(context, String brandId) async {
    onSelection(context, brandId);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: brand.mainColor,
            foregroundColor: Colors.white,
            child: Text(brand.name[0])),
        title: Text(
          brand.name,
          key: Key('title_$itemNo'),
        ),
        subtitle: Text(brand.relationship, key: Key('subtitle_$itemNo')),
        onTap: () => {_handleSelection(context, brand.id)},
      ),
    );
  }
}
