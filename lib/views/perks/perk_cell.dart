import 'package:community_app/components/clickable_avatar.dart';
import 'package:community_app/views/pages/brand_home_page.dart';
import 'package:community_app/views/perks/perk_view.dart';
import 'package:flutter/material.dart';

import 'package:community_app/models/perk_model.dart';

typedef OnDetailCallback = void Function(BuildContext context, String perkId);

class PerkCell extends StatelessWidget {
  final int itemNo;
  final PerkModel perk;
  final OnDetailCallback onDetailClick;

  const PerkCell(this.itemNo, this.perk, this.onDetailClick, {Key? key})
      : super(key: key);

  void _handleClick(context, String perkId) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PerkView(perkId: perkId)));
    onDetailClick(context, perkId);
    return;
  }

  void _goToBrand(context, String brandId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BrandHomepage(brandId: brandId)));
  }

  @override
  Widget build(BuildContext context) {
    _buildBody() {
      return SizedBox(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(alignment: Alignment.topLeft, children: [
            SizedBox(
                height: 181.0,
                width: double.infinity,
                child: Image.network(
                    perk.imageUrls.isEmpty
                        ? "http://contrapoderweb.com/wp-content/uploads/2014/10/default-img-400x240.gif"
                        : perk.imageUrls[0],
                    fit: BoxFit.cover))
          ]),
          const SizedBox(height: 10),
          InkWell(
              onTap: () => _goToBrand(context, perk.brand.id),
              child: Row(
                children: [
                  ClickableAvatar(
                      avatarText: perk.brand.name[0],
                      backgroundColor: perk.brand.mainColor,
                      avatarURL: perk.brand.logoUrl,
                      radius: 15),
                  const SizedBox(width: 10),
                  Text(
                    perk.brand.name,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
              )),
          const SizedBox(height: 5),
          Text(perk.typeToString(),
              style: Theme.of(context).textTheme.subtitle2),
          const SizedBox(height: 5),
          Text(perk.title + " • " + perk.priceToString(),
              style: Theme.of(context).textTheme.headline6),
        ],
      ));
    }

    return GestureDetector(
        onTap: () => _handleClick(context, perk.id),
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [_buildBody(), const Divider()],
                ))));
  }
}
