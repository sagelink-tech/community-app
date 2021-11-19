import 'package:flutter/material.dart';
import 'package:community_app/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
  const PostView({Key? key, required this.postId}) : super(key: key);
  final String postId;

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
            print(result.data);
            _post = PostModel.fromJson(result.data?['posts'][0]);
          }
          return Scaffold(
            appBar: AppBar(
              title: result.isLoading || result.hasException
                  ? const Text('')
                  : Text(_post.title),
              actions: [
                IconButton(
                  onPressed: result.isLoading ? null : refetch,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: Center(
              child: (result.hasException
                  ? Text(result.exception.toString())
                  : result.isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            Text(_post.body),
                            Text(_post.creator.name),
                            Text(_post.commentCount.toString()),
                          ],
                        )),
            ),
          );
        });
  }
}
