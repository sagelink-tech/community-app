import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/data/models/user_model.dart';

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
        alignment: Alignment.centerLeft,
        width: double.infinity,
        height: height,
        color: Theme.of(context).backgroundColor,
        child: _buildAvatar(context));
  }
}

class BrandAuthorStackedAvatars extends StatelessWidget {
  final double height;
  final double overlap;
  final UserModel user;
  final BrandModel brand;
  final double offset = 30;
  final double borderWidth = 4;
  const BrandAuthorStackedAvatars(this.user, this.brand,
      {this.height = 44, this.overlap = 0.6, Key? key})
      : super(key: key);

  Widget _buildAvatars(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Align(
              widthFactor: overlap,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).backgroundColor,
                child: ClickableAvatar(
                  radius: height / 2 - borderWidth,
                  avatarText: brand.name[0],
                  avatarImage: brand.logoImage(),
                ),
              )),
          Align(
              widthFactor: overlap,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).backgroundColor,
                child: ClickableAvatar(
                  radius: height / 2 - borderWidth,
                  avatarText: user.name.isNotEmpty ? user.name[0] : "",
                  avatarImage: user.profileImage(),
                ),
              )),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: height,
        color: Theme.of(context).backgroundColor,
        child: _buildAvatars(context));
  }
}
