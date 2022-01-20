import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/components/universal_image_picker.dart';
import 'package:sagelink_communities/models/post_model.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:collection/collection.dart';

String createPostMutation = """
mutation CreatePosts(\$input: [PostCreateInput!]!) {
  createPosts(input: \$input) {
    info {
      nodesCreated
    }
  }
}
""";

typedef OnCompletionCallback = void Function();

class NewPostPage extends ConsumerStatefulWidget {
  const NewPostPage(
      {Key? key, required this.brandId, required this.onCompleted})
      : super(key: key);
  final String brandId;
  final OnCompletionCallback onCompleted;

  static const routeName = '/posts';

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends ConsumerState<NewPostPage> {
  final formKey = GlobalKey<FormState>();
  String? title;
  String? body;
  String? linkUrl;
  PostType selectedType = PostType.text;

  int maxImages = 4;
  List<File> selectedImageFiles = [];
  late final UniversalImagePicker _imagePicker = UniversalImagePicker(context,
      maxImages: maxImages,
      onSelected: () =>
          setState(() => selectedImageFiles = _imagePicker.images));

  bool canSubmit() {
    bool hasTitle = title != null && title!.isNotEmpty;
    switch (selectedType) {
      case PostType.text:
        return hasTitle;
      case PostType.images:
        return hasTitle && selectedImageFiles.isNotEmpty;
      case PostType.link:
        return hasTitle && linkUrl != null && linkUrl!.isNotEmpty;
    }
  }

  Widget _buildPostTypeSelection(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Wrap(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "select post type",
                style: Theme.of(context).textTheme.caption,
              ),
              Wrap(
                  children: PostType.values
                      .map((e) => TextButton.icon(
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all(
                                    selectedType == e
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary)),
                            onPressed: () => setState(() {
                              selectedType = e;
                            }),
                            icon: e.iconForPostType(),
                            label: Text(e.toShortString()),
                          ))
                      .toList())
            ],
          )
        ]));
  }

  Widget _buildBody() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
            key: formKey,
            //autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildTitleForm(),
                const SizedBox(height: 16),
                selectedType == PostType.text
                    ? buildBodyForm()
                    : selectedType == PostType.images
                        ? buildImagesForm()
                        : buildLinkForm()
              ],
            )));
  }

  Widget buildTitleForm({bool enabled = true}) => TextFormField(
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          errorStyle: TextStyle(color: Colors.purple),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          } else {
            return null;
          }
        },
        maxLength: 200,
        minLines: 1,
        maxLines: 3,
        onChanged: (value) => setState(() => title = value),
        enabled: enabled,
      );

  Widget buildLinkForm({bool enabled = true}) => TextFormField(
        decoration: const InputDecoration(
          hintText: "Enter a url...",
          border: OutlineInputBorder(),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          errorStyle: TextStyle(color: Colors.purple),
        ),
        validator: (value) {
          if ((value != null && value.isEmpty) && Uri.parse(value).isAbsolute) {
            return 'Please enter a valid url';
          } else {
            return null;
          }
        },
        maxLength: 200,
        minLines: 1,
        maxLines: 1,
        onChanged: (value) => setState(() => linkUrl = value),
        enabled: enabled,
      );

  Widget buildBodyForm({bool enabled = true}) => TextFormField(
      decoration: const InputDecoration(
        hintText: "Enter (optional) body text...",
        border: OutlineInputBorder(),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
        focusedErrorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
        errorStyle: TextStyle(color: Colors.purple),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter body text';
        } else {
          return null;
        }
      },
      maxLength: 1000,
      minLines: 5,
      maxLines: 5,
      onChanged: (value) => setState(() => body = value),
      enabled: enabled);

  Widget buildImagesForm() {
    Widget addImageContainer = InkWell(
        onTap: _imagePicker.openImagePicker,
        child: Container(
          width: 150,
          height: 150,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Theme.of(context).dividerColor)),
          child:
              const Align(alignment: Alignment.center, child: Icon(Icons.add)),
        ));

    List<Widget> imageList = selectedImageFiles
        .mapIndexed((index, im) => Container(
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
                  child: Image.file(
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
                                  _imagePicker.removeImageAtIndex(index),
                              icon: const Icon(Icons.delete_outline)))))
            ])))
        .toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: selectedImageFiles.length >= maxImages
          ? imageList
          : [...imageList, addImageContainer],
    );
  }

  Widget buildSubmit({bool enabled = true}) => Builder(
      builder: (context) => Mutation(
          options: MutationOptions(
              document: gql(createPostMutation),
              onCompleted: (dynamic resultData) {
                widget.onCompleted();
                Navigator.pop(context);
              }),
          builder: (RunMutation runMutation, result) => IconButton(
                icon: const Icon(Icons.send),
                onPressed: enabled
                    ? () {
                        if (formKey.currentState == null) return;
                        final isValid = formKey.currentState!.validate();

                        if (isValid) {
                          runMutation({
                            "input": [
                              {
                                "title": title,
                                "body": body,
                                "inBrandCommunity": {
                                  "connect": {
                                    "where": {
                                      "node": {"id": widget.brandId}
                                    }
                                  }
                                },
                                "createdBy": {
                                  "connect": {
                                    "where": {
                                      "node": {
                                        "id": ref
                                            .read(loggedInUserProvider)
                                            .getUser()
                                            .id
                                      }
                                    }
                                  }
                                }
                              }
                            ]
                          });
                        }
                      }
                    : null,
              )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Create Post"),
            actions: [
              buildSubmit(enabled: canSubmit()),
            ],
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0),
        body: Container(
            padding: const EdgeInsets.only(bottom: 5),
            alignment: AlignmentDirectional.topStart,
            child: Stack(
                children: [_buildBody(), _buildPostTypeSelection(context)])));
  }
}
