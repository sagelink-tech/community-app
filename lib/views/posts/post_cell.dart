import 'package:community_app/components/activity_badge.dart';
import 'package:community_app/components/clickable_avatar.dart';
import 'package:community_app/views/posts/post_view.dart';
import 'package:flutter/material.dart';

import 'package:community_app/models/post_model.dart';

typedef OnDetailCallback = void Function(BuildContext context, String postId);

class PostCell extends StatelessWidget {
  final int itemNo;
  final PostModel post;
  final OnDetailCallback onDetailClick;

  const PostCell(this.itemNo, this.post, this.onDetailClick, {Key? key})
      : super(key: key);

  void _handleClick(context, String postId,
      {bool withTextFocus = false}) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostView(
                postId: postId, autofocusCommentField: withTextFocus)));
    onDetailClick(context, postId);
    return;
  }

  @override
  Widget build(BuildContext context) {
    _buildTitle() {
      return Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClickableAvatar(
                avatarText: post.brand.name[0],
                avatarURL: post.brand.logoUrl,
                backgroundColor: post.brand.mainColor,
              ),
              const SizedBox(width: 10),
              Text(post.brand.name)
            ],
          ));
    }

    _buildBody() {
      return Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(post.title, style: Theme.of(context).textTheme.headline4),
              Row(
                children: [
                  ClickableAvatar(
                      avatarText: post.creator.name[0],
                      avatarURL: post.creator.accountPictureUrl),
                  const SizedBox(width: 10),
                  Text(
                    post.creator.name,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
              ),
              Text(post.body, style: Theme.of(context).textTheme.bodyText1),
              OutlinedButton(
                  onPressed: () =>
                      _handleClick(context, post.id, withTextFocus: true),
                  child: const Text("Comment"))
            ],
          ));
    }

    _buildDetail() {
      return GestureDetector(
          onTap: () => _handleClick(context, post.id),
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                const Text("Full conversation"),
                const Icon(Icons.navigate_next),
                const Spacer(),
                ActivityChip(activityCount: post.commentCount),
              ])));
    }

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // if you need this
              side: BorderSide(
                color: Colors.grey.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildTitle(),
                const Divider(),
                _buildBody(),
                const Divider(),
                _buildDetail()
              ],
            )));
  }
}
