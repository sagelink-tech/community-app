import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/image_carousel.dart';
import 'package:sagelink_communities/ui/components/link_preview.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/components/moderation_options_sheet.dart';
import 'package:sagelink_communities/ui/views/comments/new_comment.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/comments/comment_list.dart';
import 'package:sagelink_communities/ui/views/posts/new_post_view.dart';
import 'package:timeago/timeago.dart' as timeago;

String getPostQuery = """
query Posts(\$where: PostWhere, \$options: CommentOptions) {
  posts(where: \$where) {
    id
    title
    body
    type
    images
    linkUrl
    createdAt
    isFlaggedByUser
    createdBy {
      id
      name
      accountPictureUrl
      queryUserHasBlocked
    }
    inBrandCommunity {
      id
      name
      mainColor
      logoUrl
    }
    commentsAggregate {
      count
    }
    comments(options: \$options) {
      id
      body
      images
      createdAt
      isFlaggedByUser
      createdBy {
        id
        name
        accountPictureUrl
        queryUserHasBlocked
      }
      repliesAggregate {
        count
      }
    }
  }
}
""";

class PostView extends ConsumerStatefulWidget {
  const PostView(
      {Key? key, required this.postId, this.autofocusCommentField = false})
      : super(key: key);
  final String postId;
  final bool autofocusCommentField;

  static const routeName = '/posts';

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends ConsumerState<PostView> {
  PostModel _post = PostModel();
  String? _threadId;
  CommentModel? editingComment;
  bool showingThread = false;
  late bool addingComment = widget.autofocusCommentField;
  late final analytics = ref.watch(analyticsProvider);

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      analytics.setCurrentScreen(screenName: "Post View");
      analytics.logScreenView(
          screenClass: "Post View", screenName: widget.postId);
    });
    super.initState();
  }

  void setAddingComment(bool addCommentFlag) {
    setState(() {
      addingComment = addCommentFlag;
      if (!addCommentFlag) {
        editingComment = null;
      }
    });
  }

  void _showCommentThread(String commentId) {
    setState(() {
      showingThread = true;
      _threadId = commentId;
    });
  }

  void completeReplyOnThread(String commentId) {
    setState(() {
      showingThread = false;
      _threadId = null;
    });
  }

  void shouldEditCommentWithID(CommentModel comment) {
    setState(() {
      editingComment = comment;
    });
  }

  void _showOptionsModal(context, VoidCallback? refetch) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return ModerationOptionsSheet(ModerationOptionSheetType.post,
              brandId: _post.brand.id,
              post: _post,
              onComplete: refetch,
              onDelete: () =>
                  {Navigator.canPop(context) ? Navigator.pop(context) : {}},
              onEdit: () => {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => NewPostPage(
                            brandId: _post.brand.id,
                            onCompleted: () => {
                                  if (Navigator.of(context).canPop())
                                    {Navigator.of(context).pop()}
                                },
                            post: _post)))
                  });
        });
  }

  List<Widget> _buildBodyView(VoidCallback? refetch) {
    Widget detail;
    Widget detailText;
    switch (_post.type) {
      case PostType.text:
        detail = const SizedBox();
        detailText = Text(_post.body ?? "",
            style: Theme.of(context).textTheme.bodyText1);
        break;
      case PostType.images:
        detail = EmbeddedImageCarousel(
          _post.images ?? [],
          height: 200,
        );
        detailText = const SizedBox();
        break;
      case PostType.link:
        detail = LinkPreview(_post.linkUrl ?? "");
        detailText = const SizedBox();
        break;
    }

    return [
      Row(children: [
        ClickableAvatar(
          radius: 30,
          avatarText: _post.creator.initials,
          avatarURL: _post.creator.accountPictureUrl,
        ),
        const ListSpacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_post.creator.name,
                style: Theme.of(context).textTheme.bodyText1),
            Text(timeago.format(_post.createdAt),
                style: Theme.of(context).textTheme.caption),
          ],
        ),
        const Spacer(),
        IconButton(
            onPressed: () => _showOptionsModal(context, refetch),
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.more_horiz_outlined))
      ]),
      const ListSpacer(),
      detail,
      const ListSpacer(),
      Text(_post.title, style: Theme.of(context).textTheme.headline4),
      const ListSpacer(),
      detailText,
      const ListSpacer(),
    ];
  }

  Widget _buildCommentButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          primary: Theme.of(context).colorScheme.primary,
          minimumSize: const Size.fromHeight(48)),
      onPressed: () => setAddingComment(true),
      child: const Text('Comment'),
    );
  }

  Widget _buildCommentField(VoidCallback? refetch) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          color: Theme.of(context).backgroundColor,
          child: NewComment(
            focused: true,
            parentId: showingThread ? _threadId! : widget.postId,
            isReply: showingThread,
            comment: editingComment,
            onCompleted: () => {
              setAddingComment(false),
              if (refetch != null) {refetch()},
              CustomWidgets.buildSnackBar(
                  context, "Comment saved!", SLSnackBarType.success)
            },
            onLostFocus: () {
              //setAddingComment(false);
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getPostQuery),
          variables: {
            "where": {"id": widget.postId},
            "options": {
              "sort": [
                {"createdAt": "DESC"}
              ]
            }
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isNotLoading && result.data != null) {
            _post = PostModel.fromJson(result.data?['posts'][0]);
          }
          return Scaffold(
              appBar: AppBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClickableAvatar(
                        avatarText: _post.brand.initials,
                        avatarImage: _post.brand.logoImage(),
                      ),
                      Text(_post.brand.name)
                    ],
                  ),
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 1),
              body: (result.hasException
                  ? const ErrorView()
                  : result.isLoading
                      ? const Loading()
                      : Stack(children: [
                          Container(
                              alignment: AlignmentDirectional.topStart,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 10),
                              child:
                                  ListView(shrinkWrap: true, children: <Widget>[
                                ..._buildBodyView(refetch),
                                _buildCommentButton(),
                                // Responses header
                                const ListSpacer(),
                                Text(
                                    "${_post.commentCount} comment${_post.commentCount != 1 ? 's' : ''}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(fontWeight: FontWeight.bold)),
                                const ListSpacer(),
                                // Comment view
                                CommentListView(
                                  _post.comments,
                                  brandId: _post.brand.id,
                                  onAddReply: (commentId) => {
                                    completeReplyOnThread(commentId),
                                    if (refetch != null) refetch()
                                  },
                                  onUpdate: (commentId) => setState(() {}),
                                  onShowThread: _showCommentThread,
                                  onShouldReply: () => setAddingComment(true),
                                  onCloseThread: () => {
                                    setState(() {
                                      showingThread = false;
                                    }),
                                    setAddingComment(false),
                                    if (refetch != null) refetch()
                                  },
                                  onShouldEdit: (comment) => setState(() {
                                    editingComment = comment;
                                    addingComment = true;
                                  }),
                                ),
                                const ListSpacer(height: 120)
                              ])),
                          addingComment
                              ? _buildCommentField(refetch)
                              : const SizedBox(
                                  width: 1,
                                  height: 1,
                                )
                        ])));
        });
  }
}
