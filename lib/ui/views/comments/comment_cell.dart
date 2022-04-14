import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkable/linkable.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:expandable/expandable.dart';
import 'package:sagelink_communities/ui/components/image_viewer/image_detail_page.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/moderation_options_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';
import 'package:collection/collection.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';

typedef VoidCommentIDCallback = void Function(String commentId);
typedef VoidCommentCallback = void Function(CommentModel comment);

class CommentCell extends StatelessWidget {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final int itemNo;
  final CommentModel comment;
  final String brandId;
  final VoidCommentIDCallback? onShowThread;
  final VoidCallback? onShouldReply;
  final VoidCommentIDCallback? onAddReply;
  final VoidCommentIDCallback? onUpdate;
  final VoidCommentCallback? onShouldEdit;
  final bool inThreadView;
  final bool canReply;

  CommentCell(this.itemNo, this.comment,
      {required this.brandId,
      required this.onShouldReply,
      this.onAddReply,
      this.onShowThread,
      this.onUpdate,
      this.onShouldEdit,
      this.inThreadView = false,
      this.canReply = true,
      Key? key})
      : super(key: key);

  void _goToAccount(BuildContext context, String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  void _showOptionsModal(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return ModerationOptionsSheet(
            ModerationOptionSheetType.comment,
            brandId: brandId,
            comment: comment,
            onDelete: () => onUpdate != null ? onUpdate!(comment.id) : {},
            onComplete: () => onUpdate != null ? onUpdate!(comment.id) : {},
            onEdit: () => onShouldEdit != null ? onShouldEdit!(comment) : {},
          );
        });
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).selectedRowColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          )),
      child: ExpandableNotifier(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(comment.creator.name,
                style: Theme.of(context).textTheme.bodyText1),
            const Spacer(),
            IconButton(
                onPressed: () => _showOptionsModal(context),
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.more_horiz_outlined)),
          ]),
          const ListSpacer(),

          Expandable(
            collapsed: Column(
              children: [
                Linkable(
                  text: comment.body,
                  maxLines: 2,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ExpandableButton(       // <-- Collapses when tapped on
                    child: Text(
                      "Show More",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            expanded: Column(
                children: [
                  Linkable(
                      text: comment.body
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ExpandableButton(       // <-- Collapses when tapped on
                      child: Text(
                        "Show Less",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ]
            ),
          ),

          Wrap(
            children: comment.images.mapIndexed((index, im) => Container(
                width: 150,
                height: 150,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Theme.of(context).dividerColor)),
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: InkWell(
                      onTap: () async {
                        ImageViewer imageViewer = ImageViewer(imageURL: comment.images[index]);
                        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => imageViewer));
                      },
                      child: CachedNetworkImage(
                        imageUrl: comment.images[index],
                        placeholderFadeInDuration: const Duration(milliseconds: 10),
                        placeholder: (context, url) => AssetUtils.wrappedDefaultImage(
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                )
            )).toList(),
          ),
        ]),
      ),
    );
  }

  Widget _buildReactButtons(BuildContext context) {
    List<Widget> _buttons = [
      Text(timeago.format(comment.createdAt, locale: "en_short"),
          style: Theme.of(context).textTheme.caption),
      // TextButton(
      //     onPressed: () => {
      //           if (onUpdate != null) {onUpdate!(comment.id)}
      //         },
      //     style: TextButton.styleFrom(
      //       primary: Theme.of(context).colorScheme.secondary,
      //     ),
      //     child: const Text("React")),
      TextButton(
          onPressed: () => {
                if (onShowThread != null) {onShowThread!(comment.id)},
                if (onShouldReply != null) {onShouldReply!()}
              },
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text("Reply")),
      const Spacer(),
      // Text(
      //   "reactions",
      //   style: Theme.of(context).textTheme.caption,
      // )
    ];

    // If in thread view, remove the "reply" button option
    if (!canReply) {
      _buttons.removeAt(1);
    }

    return Row(children: _buttons);
  }

  Widget _buildReplies(BuildContext context) {
    if (comment.replyCount == 0 || inThreadView) {
      return const SizedBox.shrink();
    }
    return Row(children: [
      // add first comment author
      TextButton(
          onPressed: () => {
                if (onShowThread != null) {onShowThread!(comment.id)}
              },
          child: Text(comment.replyCount.toString() +
              (comment.replyCount == 1 ? " reply" : " replies"))),
    ]);
  }

  Widget _buildLeftColumn(BuildContext context) {
    List<Widget> _widgets = [
      Align(
          alignment: Alignment.topCenter,
          child: ClickableAvatar(
            avatarText: comment.creator.initials,
            avatarURL: comment.creator.accountPictureUrl,
            radius: 20,
            onTap: () => _goToAccount(context, comment.creator.id),
          ))
    ];

    return Column(
        children: _widgets, crossAxisAlignment: CrossAxisAlignment.start);
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLeftColumn(context),
      const ListSpacer(),
      Flexible(
          flex: 1,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildBody(context),
            _buildReactButtons(context),
            _buildReplies(context),
          ]))
    ]);
  }
}

class ImageViewer extends StatelessWidget {
  final String imageURL;
  const ImageViewer({Key? key, required this.imageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: ImageDetailPage(imageUrls: [imageURL], currentIndex: 0,),
          ),
        ],
      ),
    );
  }
}
