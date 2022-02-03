import 'package:expandable_text/expandable_text.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/moderation_options_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/ui/views/pages/account_page.dart';

typedef VoidCommentCallback = void Function(String commentId);

class CommentCell extends StatelessWidget {
  final int itemNo;
  final CommentModel comment;
  final String brandId;
  final VoidCommentCallback? onShowThread;
  final VoidCommentCallback? onAddReply;
  final VoidCommentCallback? onUpdate;
  final bool inThreadView;

  const CommentCell(this.itemNo, this.comment,
      {required this.brandId,
      this.onAddReply,
      this.onShowThread,
      this.onUpdate,
      this.inThreadView = false,
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
            brandId: brandId,
            comment: comment,
            onComplete: () => onUpdate != null ? onUpdate!(comment.id) : {},
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
        ExpandableText(
          comment.body,
          expandText: "show more",
          collapseText: "show less",
          animation: true,
          linkEllipsis: true,
          linkColor: Theme.of(context).colorScheme.secondaryVariant,
          collapseOnTextTap: true,
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 3,
        )
      ]),
    );
  }

  Widget _buildReactButtons(BuildContext context) {
    List<Widget> _buttons = [
      Text(timeago.format(comment.createdAt, locale: "en_short"),
          style: Theme.of(context).textTheme.caption),
      TextButton(
          onPressed: () => {
                if (onUpdate != null) {onUpdate!(comment.id)}
              },
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text("React")),
      TextButton(
          onPressed: () => {
                if (onShowThread != null) {onShowThread!(comment.id)}
              },
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text("Reply")),
      const Spacer(),
      Text(
        "reactions",
        style: Theme.of(context).textTheme.caption,
      )
    ];

    // If in thread view, remove the "reply" button option
    if (inThreadView) {
      _buttons.removeAt(2);
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
            avatarText: comment.creator.name[0],
            avatarURL: comment.creator.accountPictureUrl,
            radius: 20,
            onTap: () => _goToAccount(context, comment.creator.id),
          ))
    ];

    // if (comment.replyCount == 0) {
    //   _widgets.add(
    //     Container(
    //       constraints: const BoxConstraints(
    //           minWidth: 20, maxWidth: 30, minHeight: 25, maxHeight: 120),
    //       margin: const EdgeInsets.only(left: 20, bottom: 20),
    //       decoration: const BoxDecoration(
    //           color: Colors.transparent,
    //           borderRadius:
    //               BorderRadius.only(bottomLeft: Radius.circular(10.0)),
    //           border: Border(
    //             left: BorderSide(color: Colors.black),
    //             bottom: BorderSide(color: Colors.black),
    //           )),
    //     ),
    //   );
    // }
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
