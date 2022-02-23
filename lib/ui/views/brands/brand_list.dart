import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/ui/views/brands/brand_list_cell.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/views/login_signup/accept_invite_page.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String brandId);

class BrandListView extends StatelessWidget {
  final List<BrandModel?> brands;
  final OnSelectionCallback onSelection;
  final VoidCallback? onNewSelected;

  _handleAcceptInviteSelection(BuildContext bc) {
    showModalBottomSheet(
        context: bc,
        builder: (BuildContext context) => AcceptInvitePage(onComplete: () {
              if (onNewSelected != null) {
                onNewSelected!();
              }
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }));
  }

  _handleSelection(BuildContext bc, String? brandId) {
    if (brandId == null) {
      _handleAcceptInviteSelection(bc);
    } else {
      onSelection(bc, brandId);
    }
  }

  const BrandListView(this.brands, this.onSelection,
      {this.onNewSelected, Key? key})
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
          return BrandListCell(index, brands[index], _handleSelection);
        });
  }
}
