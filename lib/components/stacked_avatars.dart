import 'dart:math';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/models/user_model.dart';

class StackedAvatars extends StatelessWidget {
  final double height;
  final double width;
  final double overlap;
  final String overflowText;
  final List<UserModel> users;
  final bool showOverflow;
  final double offset = 30;
  final int maxAvatars = 3;
  final double borderWidth = 4;
  const StackedAvatars(this.users,
      {this.height = 44,
      this.width = 180,
      this.overlap = 0.6,
      this.showOverflow = true,
      this.overflowText = "& others",
      Key? key})
      : super(key: key);

  Widget _buildAvatar(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: min(users.length, maxAvatars + 1),
        itemBuilder: (context, index) {
          if (index == maxAvatars) {
            return Align(
                widthFactor: 1.5,
                child: Center(
                    child: Text(overflowText,
                        style: Theme.of(context).textTheme.bodyText2)));
          }
          return Align(
              widthFactor: overlap,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).backgroundColor,
                child: ClickableAvatar(
                  radius: height / 2 - borderWidth,
                  avatarText: users[index].name[0],
                  avatarURL: users[index].accountPictureUrl,
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: height,
        color: Theme.of(context).backgroundColor,
        child: _buildAvatar(context));
  }
}
