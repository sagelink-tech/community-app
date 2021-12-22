import 'package:sagelink_communities/components/activity_badge.dart';
import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/views/brands/brand_home_page.dart';
import 'package:sagelink_communities/views/posts/post_view.dart';
import 'package:flutter/material.dart';

import 'package:sagelink_communities/models/post_model.dart';

typedef OnDetailCallback = void Function(BuildContext context, String postId);
typedef OnBrandCallback = void Function(BuildContext context, String brandId);

class PostCell extends StatelessWidget {
  final int itemNo;
  final PostModel post;
  final OnDetailCallback? onDetailClick;
  final OnBrandCallback? onBrandClick;
  final bool showBrand;

  const PostCell(this.itemNo, this.post,
      {this.showBrand = true, this.onDetailClick, this.onBrandClick, Key? key})
      : super(key: key);

  void _handleClick(context, String postId,
      {bool withTextFocus = false}) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostView(
                postId: postId, autofocusCommentField: withTextFocus)));
    if (onDetailClick != null) {
      onDetailClick!(context, postId);
    }
    return;
  }

  void _handleBrandClick(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BrandHomepage(brandId: post.brand.id)));
    if (onBrandClick != null) {
      onBrandClick!(context, post.brand.id);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    _buildTitle() {
      return InkWell(
          onTap: () => _handleBrandClick(context),
          child: Container(
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
              )));
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
      return InkWell(
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

    List<Widget> _composeChildren() {
      return showBrand
          ? ([
              _buildTitle(),
              const Divider(),
              _buildBody(),
              const Divider(),
              _buildDetail()
            ])
          : ([_buildBody(), const Divider(), _buildDetail()]);
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
              children: _composeChildren(),
            )));
  }
}
