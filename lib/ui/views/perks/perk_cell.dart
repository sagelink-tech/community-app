import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';
import 'package:sagelink_communities/ui/views/brands/brand_home_page.dart';
import 'package:sagelink_communities/ui/views/perks/perk_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';

typedef OnDetailCallback = void Function(BuildContext context, String perkId);

class PerkCell extends StatelessWidget {
  final int itemNo;
  final PerkModel perk;
  final OnDetailCallback onDetailClick;
  final bool showBrand;

  const PerkCell(this.itemNo, this.perk, this.onDetailClick,
      {this.showBrand = true, Key? key})
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
      List<Widget> _bodyWidgets = [];
      // Add image
      _bodyWidgets.add(Stack(alignment: Alignment.topLeft, children: [
        SizedBox(
            height: 181.0,
            width: double.infinity,
            child: perk.imageUrls.isEmpty
                ? AssetUtils.defaultImage()
                : CachedNetworkImage(
                    imageUrl: perk.imageUrls[0],
                    placeholderFadeInDuration: const Duration(milliseconds: 10),
                    placeholder: (context, url) =>
                        AssetUtils.wrappedDefaultImage(
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        ),
                    fit: BoxFit.fitWidth))
      ]));

      // If showBrand, add brand details
      if (showBrand) {
        _bodyWidgets.add(const SizedBox(height: 10));
        _bodyWidgets.add(InkWell(
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
            )));
      }

      // Add perk details
      _bodyWidgets.add(const SizedBox(height: 5));
      _bodyWidgets.add(Text(perk.typeToString(),
          style: Theme.of(context).textTheme.subtitle2));
      _bodyWidgets.add(const SizedBox(height: 5));
      _bodyWidgets.add(Text(perk.title + " • " + perk.priceToString(),
          style: Theme.of(context).textTheme.headline6));

      return SizedBox(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _bodyWidgets,
      ));
    }

    return Align(
        alignment: Alignment.center,
        child: Container(
            padding: const EdgeInsets.all(10.0),
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 600),
            child: GestureDetector(
                onTap: () => _handleClick(context, perk.id),
                child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildBody()))));
  }
}
