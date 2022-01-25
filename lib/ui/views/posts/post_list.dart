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

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return posts.isNotEmpty
        ? ListView.builder(
            itemCount: posts.length,
            cacheExtent: 20,
            controller: ScrollController(),
            itemBuilder: (context, index) => PostCell(index, posts[index],
                onDetailClick: onSelection, showBrand: showBrand))
        : const EmptyResult(text: "Looks like no posts just yet...");
  }
}
