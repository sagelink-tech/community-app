import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';

import 'list_spacer.dart';

class ModerationOption {
  String title;
  Icon icon;
  VoidCallback onAction;
  bool needsConfirmation;
  String confirmationText;
  String confirmationButtonText;
  String confirmationCancelText;
  bool showAvatar;

  ModerationOption(
      {required this.title,
      required this.icon,
      required this.onAction,
      this.needsConfirmation = true,
      this.showAvatar = false,
      this.confirmationText = "Are you sure you want to do this?",
      this.confirmationButtonText = "Confirm",
      this.confirmationCancelText = "Cancel"});
}

class ModerationOptionsSheet extends ConsumerStatefulWidget {
  final PostModel? post;
  final CommentModel? comment;
  final String brandId;

  const ModerationOptionsSheet(
      {required this.brandId, this.post, this.comment, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ModerationOptionsSheetState();
}

class _ModerationOptionsSheetState
    extends ConsumerState<ModerationOptionsSheet> {
  bool get _isPost => widget.post != null;
  bool get _isComment => widget.comment != null;

  UserModel get _creatorDetails => _isPost
      ? widget.post!.creator
      : _isComment
          ? widget.comment!.creator
          : UserModel();
  String get _parentId => _isPost
      ? widget.post!.id
      : _isComment
          ? widget.comment!.id
          : "";
  late final LoggedInUser _user = ref.watch(loggedInUserProvider);

  bool isConfirming = false;
  ModerationOption? selectedOption;

  String get typeString => _isPost
      ? "post"
      : _isComment
          ? "comment"
          : "";

  bool _isValid() => _isPost || _isComment;

  List<ModerationOption> getOptions() {
    if (!_isValid()) {
      return [];
    }

    ModerationOption editOption = ModerationOption(
        title: "Edit " + typeString,
        icon: const Icon(Icons.edit_outlined),
        onAction: onEdit,
        needsConfirmation: false);
    ModerationOption removeOption = ModerationOption(
        title: "Remove " + typeString,
        icon: const Icon(Icons.delete_outlined),
        onAction: onRemove,
        confirmationText:
            "Are you sure you want to permanently remove this $typeString?",
        confirmationButtonText: "Yes, remove");
    ModerationOption flagOption = ModerationOption(
        title: "Flag " + typeString,
        icon: const Icon(Icons.edit_outlined),
        onAction: onFlag,
        confirmationText:
            "Are you sure you want to flag this $typeString to the moderators?",
        confirmationButtonText: "Yes, flag");
    ModerationOption blockUserOption = ModerationOption(
        title: "Block " + _creatorDetails.name,
        icon: const Icon(Icons.block_outlined),
        onAction: onBlockUser,
        showAvatar: true,
        confirmationText:
            "Are you sure you want to block ${_creatorDetails.name}?",
        confirmationButtonText: "Yes, block");
    ModerationOption flagUserOption = ModerationOption(
        title: "Flag " + _creatorDetails.name,
        icon: const Icon(Icons.block_outlined),
        onAction: onFlagUser,
        showAvatar: true,
        confirmationText:
            "Are you sure you want to flag ${_creatorDetails.name}? You can view flagged users in the admin portal.",
        confirmationButtonText: "Yes, flag");

    bool isCreator = (_user.getUser().id == _creatorDetails.id);
    bool isModerator = (_user.isAdmin && _user.adminBrandId == widget.brandId);

    if (isCreator) {
      return [editOption, removeOption];
    }
    if (isModerator) {
      return [removeOption, flagUserOption];
    }
    return [flagOption, blockUserOption];
  }

  Widget _buildConfirmationPage() {
    if (selectedOption == null) {
      return Container();
    }
    ModerationOption option = selectedOption!;

    List<Widget> headerWidgets = option.showAvatar
        ? [
            ClickableAvatar(
              radius: 35,
              avatarText: _creatorDetails.name[0],
              avatarImage: _creatorDetails.profileImage(),
            ),
            const ListSpacer(height: 10),
            Text(
              option.confirmationText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            )
          ]
        : [
            Text(option.confirmationText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6)
          ];

    List<Widget> buttonWidgets = [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
            // onPrimary: Theme.of(context).colorScheme.onSecondary,
            minimumSize: const Size.fromHeight(48),
            elevation: 0),
        onPressed: option.onAction,
        child: Text(option.confirmationButtonText,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onError)),
      ),
      const ListSpacer(height: 20),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
            minimumSize: const Size.fromHeight(48)),
        onPressed: complete,
        child: Text(option.confirmationCancelText),
      ),
    ];

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: (IconButton(
                    onPressed: toggleConfirmation,
                    icon: const Icon(Icons.arrow_back_outlined)))),
            ...headerWidgets,
            const ListSpacer(height: 20),
            ...buttonWidgets
          ],
        ));
  }

  void toggleConfirmation() {
    setState(() {
      isConfirming = !isConfirming;
    });
  }

  void complete() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void onEdit() {
    print('selected edit');
    complete();
  }

  void onFlag() {
    print('selected flag');
    complete();
  }

  void onRemove() {
    print('selected remove');
    complete();
  }

  void onBlockUser() {
    print('selected block user');
    complete();
  }

  void onFlagUser() {
    print('selected flag user');
    complete();
  }

  void selectOption(ModerationOption option) {
    option.needsConfirmation
        ? setState(() {
            selectedOption = option;
            isConfirming = true;
          })
        : option.onAction();
  }

  @override
  Widget build(BuildContext context) {
    return _isValid()
        ? SafeArea(
            child: isConfirming
                ? _buildConfirmationPage()
                : Wrap(
                    children: getOptions()
                        .map((option) => ListTile(
                              leading: option.icon,
                              title: Text(
                                option.title,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              onTap: () => {selectOption(option)},
                            ))
                        .toList(),
                  ),
          )
        : throw NullThrownError();
  }
}
