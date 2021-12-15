import 'package:community_app/components/clickable_avatar.dart';
import 'package:community_app/components/list_spacer.dart';
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
              child: (result.hasException
                  ? Text(result.exception.toString())
                  : result.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(children: <Widget>[
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: ListView(
                                    children: [
                                      const ListSpacer(),
                                      Text('ORIGINAL POST',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5),
                                      const ListSpacer(),
                                      Text(
                                        _post.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                      const ListSpacer(),
                                      Text(
                                        _post.body,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      const ListSpacer(),
                                      Row(
                                        children: [
                                          ClickableAvatar(
                                            radius: 30,
                                            avatarText: _post.creator.name[0],
                                            avatarURL:
                                                _post.creator.accountPictureUrl,
                                          ),
                                          const ListSpacer(),
                                          Text(_post.creator.name),
                                        ],
                                      ),
                                      const ListSpacer(),
                                      Text('RESPONSES',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5),
                                      const ListSpacer(),
                                      CommentListView(_post.comments),
                                    ],
                                  ))),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                padding: const EdgeInsets.all(20),
                                child: NewComment(
                                    focused: widget.autofocusCommentField,
                                    postId: widget.postId,
                                    onCompleted: refetch!)),
                          )
                        ])),
            ),
          );
        });
  }
}
