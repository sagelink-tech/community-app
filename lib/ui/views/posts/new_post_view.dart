import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/services/post_service.dart';
import 'package:sagelink_communities/ui/components/link_preview.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/components/universal_image_picker.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:collection/collection.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';
import 'package:sagelink_communities/ui/views/brands/community_guidelines.dart';

String createPostMutation = """
mutation CreatePosts(\$input: [PostCreateInput!]!) {
  createPosts(input: \$input) {
    posts {
      id
    }
  }
}
""";

String updatePostMutation = """
mutation UpdatePosts(\$where: PostWhere, \$update: PostUpdateInput) {
  updatePosts(where: \$where, update: \$update) {
    posts {
      id
    }
  }
}
""";

String fetchCommunityGuidelines = """
query FetchCommunityGuidelines(\$where: BrandWhere) {
  brands(where: \$where) {
    id
    communityGuidelines
  }
}
""";

typedef OnCompletionCallback = void Function();

class NewPostPage extends ConsumerStatefulWidget {
  const NewPostPage(
      {Key? key, required this.brandId, required this.onCompleted, this.post})
      : super(key: key);
  final String brandId;
  final OnCompletionCallback onCompleted;
  final PostModel? post;

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
  String communityGuidelines = "";

  bool get isUpdating => widget.post != null;

  late PostService postService = ref.watch(postServiceProvider);
  late LoggedInUser loggedInUser = ref.watch(loggedInUserProvider);
  late GraphQLClient client = ref.watch(gqlClientProvider).value;

  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    _imagePicker.clearImages();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _fetchCommunityGuidelines();
    });
    if (isUpdating) {
      selectedType = widget.post!.type;
      title = widget.post!.title;
      switch (selectedType) {
        case (PostType.text):
          body = widget.post!.body;
          break;
        case (PostType.link):
          linkUrl = widget.post!.linkUrl;
          break;
        case (PostType.images):
          isLoading = true;
          imageFilesFromPost();
          break;
      }
    }
  }

  _fetchCommunityGuidelines() async {
    QueryResult result = await client.query(
        QueryOptions(document: gql(fetchCommunityGuidelines), variables: {
      "where": {"id": widget.brandId}
    }));

    if (result.data != null && (result.data!['brands'] as List).isNotEmpty) {
      communityGuidelines = result.data!['brands'][0]['communityGuidelines'];
    }
  }

  _showCommunityGuidelines(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) => FractionallySizedBox(
            heightFactor: 0.85,
            child: CommunityGuidelines(guidelineText: communityGuidelines)));
  }

  void imageFilesFromPost() async {
    List<File> files = [];
    if (widget.post!.images != null) {
      for (String url in widget.post!.images!) {
        files.add(await AssetUtils.urlToFile(url));
      }
      setState(() {
        originalImageFiles = files;
        selectedImageFiles = files;
        isLoading = false;
      });
    } else {
      setState(() {
        originalImageFiles = [];
        selectedImageFiles = [];
        isLoading = false;
      });
    }
  }

  bool isSaving = false;
  bool isLoading = false;

  int maxImages = 4;
  List<File> originalImageFiles = [];
  List<File> selectedImageFiles = [];
  late final UniversalImagePicker _imagePicker =
      UniversalImagePicker(context, maxImages: maxImages, onSelected: () {
    if (!isDisposed) {
      setState(() => selectedImageFiles = _imagePicker.images);
    }
  },
          originalUrls: isUpdating && widget.post!.images != null
              ? widget.post!.images!
              : []);

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

  void complete() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Post submitted!"),
        backgroundColor: Theme.of(context).colorScheme.error));
    Navigator.of(context).pop();
    widget.onCompleted();
  }

  Future<bool> setImagesOnCreate(String postId) async {
    ImageUploadResult imageResults = await _imagePicker
        .uploadImages("post/$postId/", context: context, client: client);
    if (!imageResults.success) {
      // Should delete post and/or retry
      return false;
    }
    var variables = {
      "where": {"id": postId},
      "update": {"images": imageResults.locations}
    };
    QueryResult result = await client.mutate(MutationOptions(
        document: gql(updatePostMutation), variables: variables));

    if (result.hasException) {
      // Should delete and/or retry
      return false;
    } else {
      return true;
    }
  }

  void createPost() async {
    setState(() {
      isSaving = true;
    });
    QueryResult result = await client.mutate(MutationOptions(
        document: gql(createPostMutation), variables: mutationVariables()));
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Error saving post, please try again."),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
    if (result.data != null) {
      if (selectedType == PostType.images) {
        bool uploadResult = await setImagesOnCreate(
            result.data!['createPosts']['posts'][0]['id']);

        if (!uploadResult) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Error saving post, please try again."),
              backgroundColor: Theme.of(context).colorScheme.error));
        }
      }
    }
    setState(() {
      isSaving = false;
    });
    complete();
  }

  void updatePost() async {
    Map<String, dynamic> updateData = {
      "title": title,
    };
    switch (selectedType) {
      case PostType.text:
        updateData['body'] = body;
        break;
      case PostType.link:
        updateData['linkUrl'] = linkUrl;
        break;
      case PostType.images:
        ImageUploadResult imageResults = await _imagePicker.updateImages(
            "post/${widget.post!.id}/",
            context: context,
            client: client);
        if (!imageResults.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Error saving post, please try again."),
              backgroundColor: Theme.of(context).colorScheme.error));
        }
        updateData["images"] = imageResults.locations;
        break;
    }
    await postService.updatePost(widget.post!, updateData,
        onComplete: (data) => complete());
  }

  Map<String, dynamic> mutationVariables() {
    Map<String, dynamic> variables = {
      "title": title,
      "type": selectedType.toShortString(),
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
            "node": {"id": loggedInUser.getUser().id}
          }
        }
      }
    };

    switch (selectedType) {
      case (PostType.text):
        variables['body'] = body;
        break;
      case (PostType.images):
        //CREATE FIRST THEN UPLOAD IMAGES WITH POST ID
        break;
      case (PostType.link):
        variables['linkUrl'] = linkUrl;
        break;
    }

    return {
      "input": [variables]
    };
  }

  Widget _buildPostTypeSelection(BuildContext context) {
    Widget selector = Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, -1), blurRadius: 5.0)
            ],
            color: Theme.of(context).cardColor),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
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
            ]));
    return Align(
        alignment: Alignment.bottomCenter,
        child: Wrap(children: [
          Column(
              children:
                  isUpdating ? [buildSubmit()] : [selector, buildSubmit()])
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
          counterText: "",
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          } else {
            return null;
          }
        },
        textCapitalization: TextCapitalization.sentences,
        maxLength: 200,
        minLines: 1,
        maxLines: 3,
        initialValue: title,
        onChanged: (value) => setState(() => title = value),
        enabled: enabled,
      );

  Widget buildLinkForm({bool enabled = true}) {
    TextFormField form = TextFormField(
      decoration: const InputDecoration(
        hintText: "Enter a url...",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.url,
      autocorrect: false,
      minLines: 1,
      maxLines: 1,
      initialValue: linkUrl,
      onChanged: (value) => setState(() => linkUrl = value),
      enabled: enabled,
    );

    Widget? preview = linkUrl != null ? LinkPreview(linkUrl) : null;

    return Column(
      children: preview != null
          ? [form, const ListSpacer(height: 20), preview]
          : [form],
    );
  }

  Widget buildBodyForm({bool enabled = true}) => TextFormField(
      decoration: const InputDecoration(
        hintText: "Enter (optional) body text...",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter body text';
        } else {
          return null;
        }
      },
      textCapitalization: TextCapitalization.sentences,
      maxLength: 1000,
      minLines: 5,
      maxLines: 5,
      initialValue: body,
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

  Widget buildSubmit() => ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
            // onPrimary: Theme.of(context).colorScheme.onSecondary,
            minimumSize: const Size.fromHeight(48)),
        onPressed:
            canSubmit() ? () => isUpdating ? updatePost() : createPost() : null,
        child: Text("Submit",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onError)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: isUpdating
                ? const Text("Update Post")
                : const Text("Create Post"),
            actions: [
              IconButton(
                onPressed: () => _showCommunityGuidelines(context),
                icon: const Icon(Icons.info_outline),
              )
            ],
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0),
        body: Container(
            alignment: AlignmentDirectional.topStart,
            child: isSaving || isLoading
                ? const Loading()
                : Stack(children: [
                    _buildBody(),
                    _buildPostTypeSelection(context)
                  ])));
  }
}
