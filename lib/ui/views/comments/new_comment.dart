import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/services/comment_service.dart';
import 'dart:io';
import '../../components/universal_image_picker.dart';
import 'package:sagelink_communities/ui/components/universal_image_picker.dart';
import 'package:collection/collection.dart';

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
  bool isSaving = false;
  bool isLoading = false;
  bool isDisposed = false;

  int maxImages = 4;
  List<File> originalImageFiles = [];
  List<File> selectedImageFiles = [];
  late final UniversalImagePicker imagePicker = UniversalImagePicker(
      context,
      maxImages: maxImages,
      onSelected: () {
        if (!isDisposed) {
          setState(() => selectedImageFiles = imagePicker.images);
        }
      },
      originalUrls: []
  );

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
    isDisposed = true;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildBodyForm(context),
              buildSubmit(enabled: !isSaving && body != null && body!.isNotEmpty)
            ],
          ),
        ));
  }

  Widget buildBodyForm(BuildContext context, {bool enabled = true}) {
    if (isUpdate && body != widget.comment!.body) {
      setState(() {});
    }
    return Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
                focusNode: _focusNode,
                controller: _editingController,
                autofocus: widget.focused || isUpdate,
                decoration: const InputDecoration(
                    border: InputBorder.none,//OutlineInputBorder(),
                    hintText: 'Type response'
                ),
                minLines: widget.isReply ? 1 : 2,
                maxLines: 3,
                onChanged: (value) => setState(() => body = value),
                enabled: enabled
            ),
            Wrap(
              children: selectedImageFiles.mapIndexed((index, im) => Container(
                  width: 150,
                  height: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Theme.of(context).dividerColor)),
                  child: Stack(alignment: Alignment.topLeft, children: [
                    SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: kIsWeb
                            ? Image.network(im.path, fit: BoxFit.cover)
                            : Image.file(
                          im,
                          fit: BoxFit.cover,
                        )),
                    Padding(
                        padding: const EdgeInsets.all(5),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: CircleAvatar(
                                radius: 17,
                                backgroundColor: Theme.of(context).cardColor,
                                foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                                child: IconButton(
                                    iconSize: 18,
                                    onPressed: () =>
                                        imagePicker.removeImageAtIndex(index),
                                    icon: const Icon(Icons.close)))))
                  ])))
                  .toList(),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {
                imagePicker.openImagePicker();
              },
              child: Image.asset('assets/image_icon.png'),
            )
          ],
        )
    );
  }

  Future<void> updateComment() async {
    setState(() {
      isSaving = true;
    });

    await commentService.updateComment(widget.comment!, body!,
        onComplete: (data) => {
              if (widget.onLostFocus != null) {widget.onLostFocus!()},
              widget.onCompleted()
            });
    setState(() {
      isSaving = false;
    });
  }

  Future<void> createComment() async {
    if (body != null) {
      setState(() {
        isSaving = true;
      });
      if (widget.isReply) {
        await commentService.replyToCommentWithID(widget.parentId, body!, imagePicker, context,
            onComplete: (data) => widget.onCompleted());
      } else if (widget.isOnPerk) {
        await commentService.commentOnPerkWithID(widget.parentId, body!, imagePicker, context,
            onComplete: (data) => widget.onCompleted());
      } else {
        await commentService.commentOnPostWithID(widget.parentId, body!, imagePicker, context,
            onComplete: (data) => widget.onCompleted());
      }
      setState(() {
        isSaving = false;
      });
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
            isSaving
                ? "Saving..."
                : isUpdate
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
