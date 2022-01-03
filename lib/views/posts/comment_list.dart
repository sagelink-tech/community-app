import 'package:sagelink_communities/models/comment_model.dart';
import 'package:sagelink_communities/views/posts/comment_cell.dart';
import 'package:flutter/material.dart';

typedef ShowThreadCallback = void Function(
    BuildContext context, String commentId);

typedef AddReplyCallback = void Function(
    BuildContext context, String commentId);

class CommentListView extends StatelessWidget {
  final List<CommentModel> comments;

  final ShowThreadCallback? onShowThread;
  final AddReplyCallback? onAddReply;

  const CommentListView(this.comments,
      {this.onShowThread, this.onAddReply, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: comments.length,
      cacheExtent: 20,
      controller: ScrollController(),
      itemBuilder: (context, index) => CommentCell(
        index,
        comments[index],
        onAddReply: onAddReply,
        onShowThread: onShowThread,
      ),
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
