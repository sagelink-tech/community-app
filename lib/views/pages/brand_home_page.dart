import 'package:community_app/components/brand_avatar.dart';
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
                  actions: [
                    buildNewPostButton(refetch!),
                  ],
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 0),
              body: Center(
                child: (result.hasException
                    ? Text(result.exception.toString())
                    : result.isLoading
                        ? const CircularProgressIndicator()
                        : Column(children: [
                            SizedBox(
                                height: 200.0,
                                width: double.infinity,
                                child: Image.network(
                                    _brand.backgroundImageUrl.isEmpty
                                        ? "http://contrapoderweb.com/wp-content/uploads/2014/10/default-img-400x240.gif"
                                        : _brand.backgroundImageUrl,
                                    fit: BoxFit.cover)),
                            BrandAvatar(brand: _brand, radius: 50),
                            (result.isLoading || result.hasException
                                ? const Text('')
                                : const Text("VIP Community")),
                            (result.isLoading || result.hasException
                                ? const Text('')
                                : Text(_brand.followers.length.toString() +
                                    " members")),
                            (result.isLoading || result.hasException
                                ? const Text('')
                                : Text(_brand.name)),
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
                                                              postId: postId)))
                                            }
                                        }))
                          ])),
              ));
        });
  }

  Widget buildNewPostButton(OnCompletionCallback onCompleted) => IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewPostPage(
                        brandId: widget.brandId, onCompleted: onCompleted)))
          });
}
