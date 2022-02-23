import 'package:sagelink_communities/ui/components/activity_badge.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String? brandId);

class BrandListCell extends StatelessWidget {
  final int itemNo;
  final BrandModel? brand;
  final OnSelectionCallback onSelection;

  const BrandListCell(this.itemNo, this.brand, this.onSelection, {Key? key})
      : super(key: key);

  List<Widget> brandDetails(BuildContext context) {
    return [
      ClickableAvatar(
        avatarText: brand!.name[0],
        avatarURL: brand!.logoUrl,
        backgroundColor: brand!.mainColor,
        radius: 25,
      ),
      Text(brand!.name, style: Theme.of(context).textTheme.bodyText1),
      Text(brand!.totalCommunityCount.toString() + ' members',
          style: Theme.of(context).textTheme.subtitle2),
    ];
  }

  List<Widget> addNewDetails(BuildContext context) {
    return [
      Icon(
        Icons.add_outlined,
        size: 30,
        color: Theme.of(context).primaryColor,
      ),
      const ListSpacer(
        height: 20,
      ),
      Text("Click to accept an invitation",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.caption),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelection(context, brand?.id),
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.grey.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
                brand != null ? brandDetails(context) : addNewDetails(context),
          )),
    );
  }
}
