import 'package:flutter/material.dart';

import 'package:community_app/models/post_model.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String postId);

class PostCell extends StatelessWidget {
  final int itemNo;
  final PostModel post;
  final OnSelectionCallback onSelection;

  const PostCell(this.itemNo, this.post, this.onSelection, {Key? key})
      : super(key: key);

  void _handleSelection(context, String brandId) async {
    onSelection(context, brandId);
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
        trailing: IconButton(
          key: Key('icon_$itemNo'),
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            _handleSelection(context, post.id);
          },
        ),
      ),
    );
  }
}
