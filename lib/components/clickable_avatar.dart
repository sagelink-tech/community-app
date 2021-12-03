import 'package:flutter/material.dart';
import 'package:community_app/models/user_model.dart';

typedef OnTapCallback = void Function();

class ClickableAvatar extends StatelessWidget {
  final String avatarText;
  final String avatarURL;
  final double radius;
  final OnTapCallback? onTap;
  final Color? backgroundColor;

  const ClickableAvatar(
      {Key? key,
      required this.avatarText,
      this.avatarURL = "",
      this.radius = 20.0,
      this.onTap,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? Theme.of(context).splashColor,
            child: (avatarURL.isEmpty
                ? Text(avatarText.isNotEmpty ? avatarText : "SL")
                : Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image.network(avatarURL, fit: BoxFit.cover)))));
  }
}
