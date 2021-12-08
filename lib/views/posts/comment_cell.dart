import 'package:community_app/components/clickable_avatar.dart';
import 'package:community_app/components/list_spacer.dart';
import 'package:flutter/material.dart';

import 'package:community_app/models/comment_model.dart';

class CommentCell extends StatelessWidget {
  final int itemNo;
  final CommentModel comment;

  const CommentCell(this.itemNo, this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ListSpacer(),
      Row(children: [
        ClickableAvatar(
          avatarText: comment.creator.name[0],
          avatarURL: comment.creator.accountPictureUrl,
          radius: 20,
        ),
        const ListSpacer(),
        Text(
          comment.creator.name,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ]),
      const ListSpacer(),
      Text(
        comment.body,
        style: Theme.of(context).textTheme.bodyText1,
        key: Key('title_$itemNo'),
      ),
      const ListSpacer(),
    ]);
  }
}
