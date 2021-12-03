import 'package:community_app/components/brand_chip.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/post_model.dart';
import 'package:community_app/views/pages/brand_home_page.dart';
import 'package:community_app/views/posts/post_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getBrandsQuery = '''
query Brands {
  brands {
    name
    shopifyToken
    mainColor
    id
  }
}
''';

String getPostsQuery = '''
query ExampleQuery(\$options: PostOptions, \$where: PostWhere) {
  posts(options: \$options, where: \$where) {
    id
    title
    body
    createdBy {
      id
      name
      username
    }
    commentsAggregate {
      count
    }
  }
}

''';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BrandModel> selectedBrands = [];

  void _handleBrandSelection(
      BuildContext context, String? brandId, bool selected) {
    if (brandId != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BrandHomepage(brandId: brandId)));
    }
    return;
  }

  Future<List<PostModel>> _getPosts(
      GraphQLClient client, List<BrandModel> brands) async {
    Map<String, dynamic> variables = {
      "options": {
        "sort": [
          {"createdAt": "DESC"}
        ]
      }
    };

    if (brands.isNotEmpty) {
      List<String> brandIds = brands.map((e) => e.id).toList();
      variables['where'] = {
        "inBrandCommunityConnection": {
          "node": {"id_IN": brandIds}
        }
      };
    }

    QueryResult result = await client.query(QueryOptions(
      document: gql(getPostsQuery),
      variables: variables,
    ));

    if (result.data != null && (result.data!['posts'] as List).isNotEmpty) {
      List postJsons = result.data!['posts'] as List;
      return postJsons.map((e) => PostModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<BrandModel?>> _getBrands(GraphQLClient client) async {
    List<BrandModel?> _brands = [null];
    QueryResult result =
        await client.query(QueryOptions(document: gql(getBrandsQuery)));

    if (result.data != null && (result.data!['brands'] as List).isNotEmpty) {
      List brandJsons = result.data!['brands'] as List;
      _brands += brandJsons.map((e) => BrandModel.fromJson(e)).toList();
    }
    return _brands;
  }

  @override
  Widget build(BuildContext context) {
    _buildBrandChips() {
      return SizedBox(
          height: 50,
          child: GraphQLConsumer(builder: (GraphQLClient client) {
            return FutureBuilder(
                future: _getBrands(client),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(5),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(width: 5);
                      },
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) => BrandChip(
                          brand: snapshot.data[index],
                          onSelection: _handleBrandSelection),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                });
          }));
    }

    _buildPostCells() {
      return GraphQLConsumer(builder: (GraphQLClient client) {
        return FutureBuilder(
            future: _getPosts(client, selectedBrands),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return PostListView(snapshot.data, (_, postId) => {});
              } else {
                return const CircularProgressIndicator();
              }
            });
      });
    }

    return Column(children: [
      _buildBrandChips(),
      const Text('Homepage'),
      Expanded(child: _buildPostCells())
    ]);
  }
}
