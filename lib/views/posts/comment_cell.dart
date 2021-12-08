import 'package:community_app/components/clickable_avatar.dart';
import 'package:flutter/material.dart';

import 'package:community_app/models/comment_model.dart';

class CommentCell extends StatelessWidget {
  final int itemNo;
  final CommentModel comment;

  const CommentCell(this.itemNo, this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ClickableAvatar(
            avatarText: comment.creator.name[0],
            avatarURL: comment.creator.accountPictureUrl),
        Text(comment.creator.name[0]),
      ]),
      Text(
        comment.body,
        key: Key('title_$itemNo'),
      ),
    ]);
  }
}
