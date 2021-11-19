import 'package:flutter/material.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:community_app/views/posts/new_post_view.dart';
import 'package:community_app/views/posts/post_view.dart';
import 'package:community_app/views/posts/post_list.dart';

String getBrandQuery = """
query Brands(\$where: BrandWhere, \$options: BrandOptions, \$postsOptions: PostOptions) {
  brands(where: \$where, options: \$options) {
    id
    name
    description
    website
    mainColor
    posts(options: \$postsOptions) {
      commentsAggregate {
        count
      }
      createdBy {
        name
        id
        username
      }
      title
      body
      id
    }
  }
}
""";

class BrandHomepage extends StatefulWidget {
  const BrandHomepage({Key? key, required this.brandId}) : super(key: key);
  final String brandId;

  static const routeName = '/brands';

  @override
  _BrandHomepageState createState() => _BrandHomepageState();
}

class _BrandHomepageState extends State<BrandHomepage> {
  BrandModel _brand = BrandModel();
  List<PostModel> _posts = [];

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getBrandQuery),
          variables: {
            "where": {"id": widget.brandId},
            "options": {"limit": 1},
            "postsOptions": {
              "limit": 10,
              "sort": [
                {"createdAt": "DESC"}
              ]
            }
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isNotLoading &&
              result.hasException == false &&
              result.data != null) {
            _brand = BrandModel.fromJson(result.data?['brands'][0]);
            List<PostModel> posts = [];
            for (var p in result.data?['brands'][0]['posts']) {
              posts.add(PostModel.fromJson(p));
            }
            _posts = posts;
          }
          return Scaffold(
              appBar: AppBar(
                title: result.isLoading || result.hasException
                    ? const Text('')
                    : Text(_brand.name),
                backgroundColor: _brand.mainColor,
              ),
              body: Center(
                child: (result.hasException
                    ? Text(result.exception.toString())
                    : result.isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Text(_brand.description),
                                buildNewPostButton(refetch!),
                                Expanded(
                                    child: PostListView(
                                        _posts,
                                        (context, postId) => {
                                              if (postId != null)
                                                {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PostView(
                                                                  postId:
                                                                      postId)))
                                                }
                                            }))
                              ])),
              ));
        });
  }

  Widget buildNewPostButton(OnCompletionCallback onCompleted) => TextButton(
      child: const Text("New Post"),
      onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewPostPage(
                        brandId: widget.brandId, onCompleted: onCompleted)))
          });
}
