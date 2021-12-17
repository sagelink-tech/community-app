import 'package:flutter/material.dart';

class AssetUtils {
  static defaultImage(
          {BoxFit fit = BoxFit.cover, double? width, double? height}) =>
      Image(
        image: const AssetImage('assets/default_image.png'),
        fit: fit,
        width: width,
        height: height,
      );
}
