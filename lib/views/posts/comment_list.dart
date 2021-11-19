import 'package:community_app/models/comment_model.dart';
import 'package:community_app/views/posts/comment_cell.dart';
import 'package:flutter/material.dart';

class CommentListView extends StatelessWidget {
  final List<CommentModel> comments;

  const CommentListView(this.comments, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return ListView.builder(
        itemCount: comments.length,
        cacheExtent: 20,
        controller: ScrollController(),
        itemBuilder: (context, index) => CommentCell(index, comments[index]));
  }
}
