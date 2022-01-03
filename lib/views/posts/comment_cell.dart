import 'package:expandable_text/expandable_text.dart';
import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/components/list_spacer.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sagelink_communities/models/comment_model.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';

typedef ShowThreadCallback = void Function(
    BuildContext context, String commentId);

typedef AddReplyCallback = void Function(
    BuildContext context, String commentId);

class CommentCell extends StatelessWidget {
  final int itemNo;
  final CommentModel comment;
  final ShowThreadCallback? onShowThread;
  final AddReplyCallback? onAddReply;

  const CommentCell(this.itemNo, this.comment,
      {this.onAddReply, this.onShowThread, Key? key})
      : super(key: key);

  void _goToAccount(BuildContext context, String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
          alignment: Alignment.topCenter,
          child: ClickableAvatar(
            avatarText: comment.creator.name[0],
            avatarURL: comment.creator.accountPictureUrl,
            radius: 20,
            onTap: () => _goToAccount(context, comment.creator.id),
          )),
      const ListSpacer(),
      Flexible(
          flex: 1,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              comment.creator.name + " • " + timeago.format(comment.createdAt),
              style: Theme.of(context).textTheme.caption,
            ),
            const ListSpacer(),
            ExpandableText(
              comment.body,
              expandText: "show more",
              collapseText: "show less",
              animation: true,
              linkEllipsis: true,
              linkColor: Theme.of(context).colorScheme.tertiary,
              collapseOnTextTap: true,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 3,
            ),
            const ListSpacer(),
            Row(
              children: [
                TextButton(
                    onPressed: () => {
                          if (onShowThread != null)
                            {onShowThread!(context, comment.id)}
                        },
                    child: Text(comment.replyCount.toString() + " replies")),
                IconButton(
                    color: Theme.of(context).colorScheme.tertiary,
                    onPressed: () => {
                          if (onAddReply != null)
                            {onAddReply!(context, comment.id)}
                        },
                    icon: const Icon(Icons.add_comment_outlined)),
              ],
            )
          ]))
    ]);
  }
}
