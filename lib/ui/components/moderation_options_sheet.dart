import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';

class ModerationOption {
  String title;
  Icon icon;
  VoidCallback onAction;

  ModerationOption(
      {required this.title, required this.icon, required this.onAction});
}

class ModerationOptionsSheet extends ConsumerWidget {
  final PostModel? post;
  final CommentModel? comment;
  final String brandId;

  const ModerationOptionsSheet(
      {required this.brandId, this.post, this.comment, Key? key})
      : super(key: key);

  bool get _isPost => post != null;
  bool get _isComment => comment != null;

  String get typeString => _isPost
      ? "post"
      : _isComment
          ? "comment"
          : "";

  bool _isValid() => _isPost || _isComment;

  List<ModerationOption> getOptions(
      LoggedInUser loggedInUser, BuildContext context) {
    if (!_isValid()) {
      return [];
    }

    String parentId = _isPost
        ? post!.id
        : _isComment
            ? comment!.id
            : "";
    UserModel parentCreator = _isPost
        ? post!.creator
        : _isComment
            ? comment!.creator
            : UserModel();

    ModerationOption editOption = ModerationOption(
        title: "Edit " + typeString,
        icon: const Icon(Icons.edit_outlined),
        onAction: () => onEdit(context));
    ModerationOption removeOption = ModerationOption(
        title: "Remove " + typeString,
        icon: const Icon(Icons.delete_outlined),
        onAction: () => onRemove(context));
    ModerationOption flagOption = ModerationOption(
        title: "Flag " + typeString,
        icon: const Icon(Icons.edit_outlined),
        onAction: () => onFlag(context));
    ModerationOption blockUserOption = ModerationOption(
        title: "Block " + parentCreator.name,
        icon: const Icon(Icons.block_outlined),
        onAction: () => onBlock(context));
    ModerationOption flagUserOption = ModerationOption(
        title: "Flag " + parentCreator.name,
        icon: const Icon(Icons.block_outlined),
        onAction: () => onBlock(context));

    bool isCreator = (loggedInUser.getUser().id == parentCreator.id);
    bool isModerator =
        (loggedInUser.isAdmin && loggedInUser.adminBrandId == brandId);

    if (isCreator) {
      return [editOption, removeOption];
    }
    if (isModerator) {
      return [removeOption, flagUserOption];
    }
    return [flagOption, blockUserOption];
  }

  void complete(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void onEdit(BuildContext context) {
    print('selected edit');
    complete(context);
  }

  void onFlag(BuildContext context) {
    print('selected flag');
    complete(context);
  }

  void onRemove(BuildContext context) {
    print('selected remove');
    complete(context);
  }

  void onBlock(BuildContext context) {
    print('selected block');
    complete(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoggedInUser _user = ref.watch(loggedInUserProvider);
    return _isValid()
        ? SafeArea(
            child: Wrap(
              children: getOptions(_user, context)
                  .map((option) => ListTile(
                        leading: option.icon,
                        title: Text(
                          option.title,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        onTap: option.onAction,
                      ))
                  .toList(),
            ),
          )
        : throw NullThrownError();
  }
}
