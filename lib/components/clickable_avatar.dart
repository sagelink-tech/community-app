import 'package:sagelink_communities/utils/color_utils.dart';
import 'package:flutter/material.dart';

typedef OnTapCallback = void Function();

class ClickableAvatar extends StatelessWidget {
  final String avatarText;
  final String avatarURL;
  final double radius;
  final EdgeInsets padding;
  final OnTapCallback? onTap;
  final Color? backgroundColor;

  const ClickableAvatar(
      {Key? key,
      required this.avatarText,
      this.avatarURL = "",
      this.radius = 20.0,
      this.onTap,
      this.backgroundColor,
      this.padding = const EdgeInsets.all(0.0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = backgroundColor ?? Theme.of(context).splashColor;

    return Container(
        padding: padding,
        child: InkWell(
            onTap: onTap,
            child: CircleAvatar(
                foregroundColor: ColorUtils.isColorLight(bgColor)
                    ? Colors.black
                    : Colors.white,
                radius: radius,
                backgroundColor: bgColor,
                backgroundImage:
                    avatarURL.isNotEmpty ? NetworkImage(avatarURL) : null,
                child: (avatarURL.isEmpty
                    ? Text(avatarText.isNotEmpty ? avatarText : "SL")
                    : null))));
  }
}
