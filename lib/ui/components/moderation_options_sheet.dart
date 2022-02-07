import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/services/comment_service.dart';
import 'package:sagelink_communities/data/services/post_service.dart';
import 'package:sagelink_communities/data/services/user_service.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';

import 'list_spacer.dart';

enum ModerationOptionSheetType { post, comment, user }

class ModerationOption {
  String title;
  Icon icon;
  VoidCallback onAction;
  bool needsConfirmation;
  String confirmationText;
  String confirmationButtonText;
  String confirmationCancelText;
  bool showAvatar;
  VoidCallback? onComplete;

  ModerationOption({
    required this.title,
    required this.icon,
    required this.onAction,
    this.needsConfirmation = true,
    this.showAvatar = false,
    this.confirmationText = "Are you sure you want to do this?",
    this.confirmationButtonText = "Confirm",
    this.confirmationCancelText = "Cancel",
  });
}

class ModerationOptionsSheet extends ConsumerStatefulWidget {
  final ModerationOptionSheetType type;
  final PostModel? post;
  final CommentModel? comment;
  final UserModel? user;
  final String? brandId;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const ModerationOptionsSheet(this.type,
      {this.brandId,
      this.onComplete,
      this.post,
      this.comment,
      this.user,
      this.onDelete,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ModerationOptionsSheetState();
}

class _ModerationOptionsSheetState
    extends ConsumerState<ModerationOptionsSheet> {
  UserModel get _relatedUserDetails {
    switch (widget.type) {
      case ModerationOptionSheetType.post:
        return widget.post!.creator;
      case ModerationOptionSheetType.comment:
        return widget.comment!.creator;
      case ModerationOptionSheetType.user:
        return widget.user!;
    }
  }

  late final LoggedInUser _user = ref.watch(loggedInUserProvider);
  late final CommentService commentService = ref.watch(commentServiceProvider);
  late final PostService postService = ref.watch(postServiceProvider);
  late final UserService userService = ref.watch(userServiceProvider);

  bool isConfirming = false;
  ModerationOption? selectedOption;

  String get typeString {
    switch (widget.type) {
      case ModerationOptionSheetType.post:
        return "post";
      case ModerationOptionSheetType.comment:
        return "comment";
      case ModerationOptionSheetType.user:
        return "user";
    }
  }

  bool _isValid() {
    switch (widget.type) {
      case ModerationOptionSheetType.post:
        return widget.post != null;
      case ModerationOptionSheetType.comment:
        return widget.comment != null;
      case ModerationOptionSheetType.user:
        return widget.user != null;
    }
  }

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
        icon: const Icon(Icons.flag_outlined),
        onAction: onFlag,
        confirmationText:
            "Are you sure you want to flag this $typeString to the moderators?",
        confirmationButtonText: "Yes, flag");
    ModerationOption blockUserOption = ModerationOption(
        title: "Block " + _relatedUserDetails.name,
        icon: const Icon(Icons.block_outlined),
        onAction: onBlockUser,
        showAvatar: true,
        confirmationText:
            "Are you sure you want to block ${_relatedUserDetails.name}?",
        confirmationButtonText: "Yes, block");
    ModerationOption unblockUserOption = ModerationOption(
        title: "Unblock " + _relatedUserDetails.name,
        icon: const Icon(Icons.check_circle_outline_outlined),
        onAction: onUnblockUser,
        showAvatar: true,
        confirmationText:
            "Are you sure you want to unblock ${_relatedUserDetails.name}?",
        confirmationButtonText: "Yes, unblock");
    ModerationOption flagUserOption = ModerationOption(
        title: "Flag " + _relatedUserDetails.name,
        icon: const Icon(Icons.report_problem_outlined),
        onAction: onFlag,
        showAvatar: true,
        confirmationText:
            "Are you sure you want to flag ${_relatedUserDetails.name}? You can view flagged users in the admin portal.",
        confirmationButtonText: "Yes, flag");

    bool isCreator = (_user.getUser().id == _relatedUserDetails.id);
    bool isModerator = (_user.isAdmin &&
        widget.brandId != null &&
        _user.adminBrandId == widget.brandId);

    switch (widget.type) {
      case ModerationOptionSheetType.user:
        {
          return [
            _relatedUserDetails.queryUserHasBlocked
                ? unblockUserOption
                : blockUserOption
          ];
        }
      default:
        {
          if (isCreator) {
            return [editOption, removeOption];
          }
          if (isModerator) {
            return [removeOption, flagUserOption, flagOption];
          }
          return [
            flagOption,
            _relatedUserDetails.queryUserHasBlocked
                ? unblockUserOption
                : blockUserOption
          ];
        }
    }
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
              avatarText: _relatedUserDetails.name[0],
              avatarImage: _relatedUserDetails.profileImage(),
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

  void complete({bool isDeleting = false}) {
    if (widget.onComplete != null && !isDeleting) {
      widget.onComplete!();
    }
    if (widget.onDelete != null && isDeleting) {
      widget.onDelete!();
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void onEdit() {
    //TODO
    print('selected edit');
    complete();
  }

  void onFlag() {
    switch (widget.type) {
      case ModerationOptionSheetType.post:
        postService.flagPost(
          widget.post!,
          onComplete: (data) => complete(),
        );
        break;
      case ModerationOptionSheetType.comment:
        commentService.flagComment(
          widget.comment!,
          onComplete: (data) => complete(),
        );
        break;
      case ModerationOptionSheetType.user:
        userService.flagUser(
          _relatedUserDetails,
          _user.adminBrandId!,
          onComplete: (data) => complete(),
        );
        break;
    }
  }

  void onRemove() {
    switch (widget.type) {
      case ModerationOptionSheetType.post:
        postService.removePost(
          widget.post!,
          onComplete: (data) => complete(isDeleting: true),
        );
        break;
      case ModerationOptionSheetType.comment:
        commentService.removeComment(
          widget.comment!,
          widget.brandId!,
          onComplete: (data) => complete(isDeleting: true),
        );
        break;
      case ModerationOptionSheetType.user:
        break;
    }
  }

  void onBlockUser() {
    userService.blockUser(_relatedUserDetails,
        onComplete: (data) => complete());
  }

  void onUnblockUser() {
    userService.unblockUser(_relatedUserDetails,
        onComplete: (data) => complete());
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
