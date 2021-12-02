import 'package:flutter/material.dart';
import 'package:community_app/models/brand_model.dart';

class BrandAvatar extends StatelessWidget {
  final BrandModel brand;
  final double radius;

  const BrandAvatar({Key? key, required this.brand, this.radius = 20.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: radius,
        backgroundColor: brand.mainColor,
        child: (brand.logoUrl.isEmpty
            ? Text(brand.name[0])
            : Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.network(brand.logoUrl, fit: BoxFit.cover))));
  }
}
