import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:flutter/material.dart';

typedef OnSelectionCallback = void Function(BrandModel? brand, bool selected);
typedef OnTapCallback = void Function(BrandModel? brand);

class BrandChip extends StatelessWidget {
  final BrandModel? brand;
  final bool selected;
  final OnSelectionCallback? onSelection;
  final OnTapCallback? onTap;

  const BrandChip(
      {Key? key,
      required this.brand,
      this.onSelection,
      this.onTap,
      this.selected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
        avatar: brand != null
            ? ClickableAvatar(
                avatarText: brand!.initials,
                avatarURL: brand!.logoUrl,
                backgroundColor: brand!.mainColor,
                radius: 15,
              )
            : null,
        label: brand != null ? Text(brand!.name) : const Text("My brands"),
        selected: selected,
        side: BorderSide(
            color: selected
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).primaryColor,
            width: selected ? 2.0 : 1.0),
        backgroundColor: Colors.transparent,
        selectedColor: Colors.transparent,
        //shape: const StadiumBorder(side: BorderSide()),
        onSelected: onSelection != null
            ? (bool value) => {onSelection!(brand, value)}
            : null,
        onPressed: onTap != null ? () => {onTap!(brand)} : null);
  }
}
