import 'package:community_app/components/brand_avatar.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:flutter/material.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String? brandId, bool selected);

class BrandChip extends StatelessWidget {
  final int activityCount;
  final BrandModel? brand;
  final bool selected;
  final OnSelectionCallback onSelection;

  const BrandChip(
      {Key? key,
      required this.brand,
      required this.activityCount,
      required this.onSelection,
      this.selected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
        avatar: brand != null
            ? BrandAvatar(
                brand: brand!,
                radius: 10,
              )
            : null,
        label: brand != null ? Text(brand!.name) : const Text("My brands"),
        selected: selected,
        onSelected: (bool value) =>
            {onSelection(context, brand != null ? brand!.id : null, value)});
  }
}
