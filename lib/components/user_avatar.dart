import 'package:flutter/material.dart';
import 'package:community_app/models/user_model.dart';

typedef OnTapCallback = void Function();

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;
  final OnTapCallback? onTap;

  const UserAvatar(
      {Key? key, required this.user, this.radius = 20.0, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).splashColor,
            child: (user.accountPictureUrl.isEmpty
                ? Text(user.name[0])
                : Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image.network(user.accountPictureUrl,
                        fit: BoxFit.cover)))));
  }
}
