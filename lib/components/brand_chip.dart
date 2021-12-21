import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/models/brand_model.dart';
import 'package:flutter/material.dart';

typedef OnSelectionCallback = void Function(BrandModel? brand, bool selected);

class BrandChip extends StatelessWidget {
  final BrandModel? brand;
  final bool selected;
  final OnSelectionCallback onSelection;

  const BrandChip(
      {Key? key,
      required this.brand,
      required this.onSelection,
      this.selected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
        avatar: brand != null
            ? ClickableAvatar(
                avatarText: brand!.name[0],
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
        onSelected: (bool value) => {onSelection(brand, value)});
  }
}
