import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/image_carousel.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/views/comments/new_comment.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/comments/comment_list.dart';
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
    createdBy {
      id
      name
      accountPictureUrl
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
      createdAt
      createdBy {
        id
        name
        accountPictureUrl
      }
      repliesAggregate {
        count
      }
    }
  }
}
""";

class PostView extends StatefulWidget {
  const PostView(
      {Key? key, required this.postId, this.autofocusCommentField = false})
      : super(key: key);
  final String postId;
  final bool autofocusCommentField;

  static const routeName = '/posts';

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  PostModel _post = PostModel();
  String? _threadId;
  bool showingThread = false;

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

  List<Widget> _buildBodyView() {
    Widget detail;
    switch (_post.type) {
      case PostType.text:
        detail = Text(_post.body ?? "",
            style: Theme.of(context).textTheme.bodyText1);
        break;
      case PostType.images:
        detail = EmbeddedImageCarousel(
          _post.images ?? [],
          height: 200,
        );
        break;
      case PostType.link:
        detail = Text(_post.linkUrl ?? "",
            style: Theme.of(context).textTheme.bodyText1);
        break;
    }

    return [
      const ListSpacer(),
      Text('ORIGINAL POST', style: Theme.of(context).textTheme.headline5),
      const ListSpacer(),
      Text(_post.title, style: Theme.of(context).textTheme.headline4),
      const ListSpacer(),
      detail,
      const ListSpacer(),
      Row(children: [
        ClickableAvatar(
          radius: 30,
          avatarText: _post.creator.name[0],
          avatarURL: _post.creator.accountPictureUrl,
        ),
        const ListSpacer(),
        Text(_post.creator.name + " • " + timeago.format(_post.createdAt),
            style: Theme.of(context).textTheme.caption),
      ]),
    ];
  }

  _buildCommentField(VoidCallback? refetch) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: NewComment(
              focused: widget.autofocusCommentField,
              parentId: showingThread ? _threadId! : widget.postId,
              isReply: showingThread,
              onCompleted: () => {
                    if (refetch != null) {refetch()}
                  })),
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
                  title: const Text(''),
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 1),
              body: (result.hasException
                  ? const ErrorView()
                  : result.isLoading
                      ? const Loading()
                      : Container(
                          alignment: AlignmentDirectional.topStart,
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Stack(children: [
                            ListView(shrinkWrap: true, children: <Widget>[
                              ..._buildBodyView(),
                              // Responses header
                              const ListSpacer(),
                              Text('RESPONSES',
                                  style: Theme.of(context).textTheme.headline5),
                              const ListSpacer(),
                              // Comment view
                              CommentListView(
                                _post.comments,
                                onAddReply: (commentId) => {
                                  completeReplyOnThread(commentId),
                                  if (refetch != null) refetch()
                                },
                                onShowThread: _showCommentThread,
                                onCloseThread: () => {
                                  setState(() {
                                    showingThread = false;
                                  }),
                                  if (refetch != null) refetch()
                                },
                              ),
                              const ListSpacer(height: 60)
                            ]),
                            _buildCommentField(refetch)
                          ]))));
        });
  }
}
