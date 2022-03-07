import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sagelink_communities/ui/components/empty_result.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/ui/views/posts/post_cell.dart';
import 'package:flutter/material.dart';

typedef OnSelectionCallback = void Function(
    BuildContext context, String? postId);

class PostListView extends StatelessWidget {
  final List<PostModel> posts;
  final OnSelectionCallback onSelection;
  final bool showBrand;

  const PostListView(this.posts, this.onSelection,
      {this.showBrand = true, Key? key})
      : super(key: key);

  Widget _buildList(BuildContext context, bool showGrid) {
    double minWidth = 450;
    double spacing = 20;
    int colCount = max(
        1,
        min(MediaQuery.of(context).size.width ~/ (minWidth + spacing).floor(),
            3));

    if (!showGrid || colCount == 1) {
      return ListView.separated(
          itemCount: posts.length,
          cacheExtent: 20,
          controller: ScrollController(),
          separatorBuilder: (context, index) => Divider(
                thickness: 8,
                color: Colors.grey.shade300,
              ),
          itemBuilder: (context, index) => PostCell(index, posts[index],
              onDetailClick: onSelection, showBrand: showBrand));
    } else {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing),
          itemCount: posts.length,
          itemBuilder: (context, index) => Card(
              semanticContainer: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: PostCell(index, posts[index],
                  onDetailClick: onSelection, showBrand: showBrand)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return posts.isNotEmpty
        ? _buildList(context, kIsWeb)
        : const EmptyResult(text: "Looks like no posts just yet...");
  }
}
