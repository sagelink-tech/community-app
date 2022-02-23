import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/services/comment_service.dart';

class NewComment extends ConsumerStatefulWidget {
  const NewComment(
      {Key? key,
      required this.parentId,
      required this.onCompleted,
      required this.onLostFocus,
      this.focused = false,
      this.isOnPerk = false,
      this.isReply = false,
      this.comment})
      : super(key: key);

  // If a comment is set, then this will be an update module, else it's a new comment
  final CommentModel? comment;
  final String parentId;
  final VoidCallback onCompleted;
  final VoidCallback? onLostFocus;
  final bool focused;
  final bool isReply;
  final bool isOnPerk;

  static const routeName = '/comments';

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends ConsumerState<NewComment> {
  final formKey = GlobalKey<FormState>();
  bool get isUpdate => widget.comment != null;
  String? body;
  late CommentService commentService = ref.watch(commentServiceProvider);
  final TextEditingController _editingController = TextEditingController();

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editingController.text.isEmpty) {
        if (widget.onLostFocus != null) {
          widget.onLostFocus!();
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _focusNode.dispose();
    _editingController.dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {
      body = isUpdate ? widget.comment!.body : "";
      _editingController.value = TextEditingValue(
        text: body!,
        selection: TextSelection.fromPosition(
          TextPosition(offset: body!.length),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isUpdate && body == null) {
      refresh();
    }
    return Form(
        key: formKey,
        //autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBodyForm(context),
            buildSubmit(enabled: body != null && body!.isNotEmpty)
          ],
        ));
  }

  Widget buildBodyForm(BuildContext context, {bool enabled = true}) {
    if (isUpdate && body != widget.comment!.body) {
      setState(() {});
    }
    return Container(
        padding: const EdgeInsets.all(10.0),
        color: Theme.of(context).canvasColor,
        child: TextFormField(
            focusNode: _focusNode,
            controller: _editingController,
            autofocus: widget.focused || isUpdate,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            minLines: widget.isReply ? 1 : 2,
            maxLines: 3,
            onChanged: (value) => setState(() => body = value),
            enabled: enabled));
  }

  void updateComment() {
    commentService.updateComment(widget.comment!, body!,
        onComplete: (data) => {
              if (widget.onLostFocus != null) {widget.onLostFocus!()},
              widget.onCompleted()
            });
  }

  void createComment() {
    if (body != null) {
      if (widget.isReply) {
        commentService.replyToCommentWithID(widget.parentId, body!,
            onComplete: (data) => widget.onCompleted());
      } else if (widget.isOnPerk) {
        commentService.commentOnPerkWithID(widget.parentId, body!,
            onComplete: (data) => widget.onCompleted());
      } else {
        commentService.commentOnPostWithID(widget.parentId, body!,
            onComplete: (data) => widget.onCompleted());
      }
    }
  }

  Widget buildSubmit({bool enabled = true}) => ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            primary: Theme.of(context).colorScheme.secondary,
            // onPrimary: Theme.of(context).colorScheme.onSecondary,
            minimumSize: const Size.fromHeight(48)),
        onPressed: enabled
            ? () {
                if (formKey.currentState == null) return;
                final isValid = formKey.currentState!.validate();

                if (isValid) {
                  isUpdate ? updateComment() : createComment();
                }
              }
            : null,
        child: Text(
            isUpdate
                ? "Save Changes"
                : widget.isReply
                    ? 'Reply'
                    : 'Comment',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onError)),
      );
}
