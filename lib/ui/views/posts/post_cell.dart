import 'package:firebase_auth/firebase_auth.dart';
import 'package:sagelink_communities/ui/components/activity_badge.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/image_carousel.dart';
import 'package:sagelink_communities/ui/components/link_preview.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/moderation_options_sheet.dart';
import 'package:sagelink_communities/ui/components/stacked_avatars.dart';
import 'package:sagelink_communities/ui/views/brands/brand_home_page.dart';
import 'package:sagelink_communities/ui/views/posts/new_post_view.dart';
import 'package:sagelink_communities/ui/views/posts/post_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/post_model.dart';

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

  void _showOptionsModal(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return ModerationOptionsSheet(
            ModerationOptionSheetType.post,
            brandId: post.brand.id,
            post: post,
            onEdit: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => NewPostPage(
                      brandId: post.brand.id,
                      onCompleted: () => {},
                      post: post)))
            },
          );
        });
  }

  String timestamp() {
    return " · " + timeago.format(post.createdAt, locale: "en_short");
  }

  @override
  Widget build(BuildContext context) {
    _buildTitle() {
      return InkWell(
          onTap: () => _handleBrandClick(context),
          child: Row(
            children: [
              BrandAuthorStackedAvatars(post.creator, post.brand),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.creator.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    post.brand.name + timestamp(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                  onPressed: () => _showOptionsModal(context),
                  color: Theme.of(context).colorScheme.primary,
                  icon: const Icon(Icons.more_horiz_outlined))
            ],
          ));
    }

    _buildBody() {
      Widget detail;
      switch (post.type) {
        case PostType.text:
          detail = const SizedBox();
          break;
        case PostType.images:
          detail = EmbeddedImageCarousel(
            post.images ?? [],
            height: 200,
            showFullscreenButton: false,
          );
          break;
        case PostType.link:
          detail = LinkPreview(post.linkUrl ?? "");
          break;
      }
      Widget bodyText = post.type == PostType.text
          ? Text(post.body ?? "", style: Theme.of(context).textTheme.bodyText1)
          : const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          detail,
          const ListSpacer(
            height: 10,
          ),
          Text(post.title,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.start),
          bodyText
        ],
      );
    }

    _buildDetail() {
      return InkWell(
          onTap: () => _handleClick(context, post.id),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "View post",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                "${post.commentCount} comments",
                style: Theme.of(context).textTheme.caption,
              )
            ]),
            const Spacer(),
            const Icon(Icons.arrow_forward_outlined),
          ]));
    }

    List<Widget> _composeChildren() {
      return showBrand
          ? ([
              _buildTitle(),
              const ListSpacer(
                height: 10,
              ),
              _buildBody(),
              const ListSpacer(
                height: 10,
              ),
              Divider(
                color: Colors.grey.shade800,
              ),
              _buildDetail()
            ])
          : ([_buildBody(), const Divider(), _buildDetail()]);
    }

    return Align(
        alignment: Alignment.center,
        child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 600),
            child: Column(
              children: _composeChildren(),
            )));
  }
}
