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
  static wrappedDefaultImage(
          {BoxFit fit = BoxFit.cover, double? width, double? height}) =>
      SizedBox(
          width: width,
          height: height,
          child: Image(
            image: const AssetImage('assets/default_image.png'),
            fit: fit,
            width: double.infinity,
            height: double.infinity,
          ));
}
