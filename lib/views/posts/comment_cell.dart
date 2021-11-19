import 'package:flutter/material.dart';

import 'package:community_app/models/comment_model.dart';

class CommentCell extends StatelessWidget {
  final int itemNo;
  final CommentModel comment;

  const CommentCell(this.itemNo, this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            child: Text(comment.creator.name[0])),
        title: Text(
          comment.body,
          key: Key('title_$itemNo'),
        ),
      ),
    );
  }
}
