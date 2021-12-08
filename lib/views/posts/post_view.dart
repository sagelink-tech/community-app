import 'package:community_app/components/clickable_avatar.dart';
import 'package:community_app/views/posts/new_comment.dart';
import 'package:flutter/material.dart';
import 'package:community_app/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:community_app/views/posts/comment_list.dart';

String getPostQuery = """
query Posts(\$where: PostWhere, \$options: CommentOptions) {
  posts(where: \$where) {
    id
    title
    body
    createdAt
    createdBy {
      id
      name
      username
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
        username
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
                title: result.isLoading || result.hasException
                    ? const Text('')
                    : Text(_post.brand.name),
                backgroundColor: Theme.of(context).backgroundColor,
                elevation: 1),
            body: Container(
              alignment: AlignmentDirectional.topStart,
              padding: const EdgeInsets.all(10),
              child: (result.hasException
                  ? Text(result.exception.toString())
                  : result.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(children: <Widget>[
                          Expanded(
                              child: ListView(
                            children: [
                              Text(
                                _post.title,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              Text(
                                _post.body,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Row(
                                children: [
                                  ClickableAvatar(
                                    avatarText: _post.creator.name[0],
                                    avatarURL: _post.creator.accountPictureUrl,
                                  ),
                                  Text(_post.creator.name),
                                ],
                              ),
                              Text('RESPONSES',
                                  style: Theme.of(context).textTheme.headline6),
                              CommentListView(_post.comments),
                            ],
                          )),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: NewComment(
                                  focused: widget.autofocusCommentField,
                                  postId: widget.postId,
                                  onCompleted: refetch!)),
                        ])),
            ),
          );
        });
  }
}
