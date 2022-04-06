import 'package:sagelink_communities/ui/components/alert_badge.dart';
import 'package:sagelink_communities/ui/utils/color_utils.dart';
import 'package:flutter/material.dart';

typedef OnTapCallback = void Function();

class ClickableAvatar extends StatelessWidget {
  final String avatarText;
  final String avatarURL;
  final Image? avatarImage;
  final double radius;
  final EdgeInsets padding;
  final OnTapCallback? onTap;
  final Color? backgroundColor;
  final bool showBadge;

  const ClickableAvatar(
      {Key? key,
      required this.avatarText,
      this.avatarURL = "",
      this.avatarImage,
      this.showBadge = false,
      this.radius = 20.0,
      this.onTap,
      this.backgroundColor,
      this.padding = const EdgeInsets.all(0.0)})
      : super(key: key);

  ImageProvider? getImage() {
    if (avatarImage != null) {
      return avatarImage!.image;
    } else {
      return avatarURL.isNotEmpty ? NetworkImage(avatarURL) : null;
    }
  }

  Widget? getText() {
    return (avatarURL.isEmpty && avatarImage == null
        ? Text(avatarText.isNotEmpty ? avatarText : "")
        : null);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = backgroundColor ?? Theme.of(context).splashColor;
    Widget avatar = CircleAvatar(
        foregroundColor:
            ColorUtils.isColorLight(bgColor) ? Colors.black : Colors.white,
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: getImage(),
        child: getText());

    return Container(
        padding: padding,
        child: InkWell(
            onTap: onTap,
            child: Stack(
                alignment: Alignment.topRight,
                children:
                    showBadge ? [avatar, const AlertBadge()] : [avatar])));
  }
}
