import 'package:flutter/material.dart';

import 'package:community_app/models/post_model.dart';

typedef OnDetailCallback = void Function(BuildContext context, String postId);

class PostCell extends StatelessWidget {
  final int itemNo;
  final PostModel post;
  final OnDetailCallback onDetailClick;

  const PostCell(this.itemNo, this.post, this.onDetailClick, {Key? key})
      : super(key: key);

  void _handleClick(context, String brandId) async {
    onDetailClick(context, brandId);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            child: Text(post.creator.name[0])),
        title: Text(
          post.title,
          key: Key('title_$itemNo'),
        ),
        subtitle: Column(
            children: [
              Text(post.body),
              Text(post.commentCount.toString() + " comments")
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            key: Key('subtitle_$itemNo')),
        onTap: () => _handleClick(context, post.id),
      ),
    );
  }
}
