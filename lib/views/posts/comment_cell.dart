import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/components/list_spacer.dart';
import 'package:flutter/material.dart';

import 'package:sagelink_communities/models/comment_model.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';

class CommentCell extends StatelessWidget {
  final int itemNo;
  final CommentModel comment;

  const CommentCell(this.itemNo, this.comment, {Key? key}) : super(key: key);

  void _goToAccount(BuildContext context, String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ListSpacer(),
      InkWell(
          onTap: () => _goToAccount(context, comment.creator.id),
          child: Row(children: [
            ClickableAvatar(
              avatarText: comment.creator.name[0],
              avatarURL: comment.creator.accountPictureUrl,
              radius: 20,
            ),
            const ListSpacer(),
            Text(
              comment.creator.name,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ])),
      const ListSpacer(),
      Text(
        comment.body,
        style: Theme.of(context).textTheme.bodyText1,
        key: Key('title_$itemNo'),
      ),
      const ListSpacer(),
    ]);
  }
}
