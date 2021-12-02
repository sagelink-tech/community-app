import 'package:community_app/components/activity_badge.dart';
import 'package:community_app/components/brand_avatar.dart';
import 'package:flutter/material.dart';
import 'package:community_app/models/brand_model.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String brandId);

class BrandListCell extends StatelessWidget {
  final int itemNo;
  final BrandModel brand;
  final OnSelectionCallback onSelection;

  const BrandListCell(this.itemNo, this.brand, this.onSelection, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelection(context, brand.id),
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.grey.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(children: [
            ListTile(
                title: null,
                trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    // ignore: avoid_print
                    onPressed: () => print('test'))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BrandAvatar(brand: brand, radius: 25),
                Text(brand.name, style: Theme.of(context).textTheme.bodyText1),
                Text(brand.followers.length.toString() + ' members',
                    style: Theme.of(context).textTheme.subtitle2),
                const ActivityChip(activityCount: 0),
              ],
            )
          ])),
    );
  }
}
