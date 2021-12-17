import 'package:sagelink_communities/models/comment_model.dart';
import 'package:sagelink_communities/views/posts/comment_cell.dart';
import 'package:flutter/material.dart';

class CommentListView extends StatelessWidget {
  final List<CommentModel> comments;

  const CommentListView(this.comments, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: comments.length,
      cacheExtent: 20,
      controller: ScrollController(),
      itemBuilder: (context, index) => CommentCell(index, comments[index]),
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
