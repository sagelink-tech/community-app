import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/brand_chip.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/ui/views/posts/post_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getBrandsQuery = '''
query Brands {
  brands {
    name
    logoUrl
    shopifyToken
    mainColor
    id
  }
}
''';

String getPostsQuery = '''
query GetPostsQuery(\$options: PostOptions, \$where: PostWhere) {
  posts(options: \$options, where: \$where) {
    id
    title
    body
    linkUrl
    images
    type
    isFlaggedByUser
    createdBy {
      id
      name
      accountPictureUrl
      isBlockedByUser
    }
    commentsAggregate {
      count
    }
    inBrandCommunity {
      id
      name
      mainColor
      logoUrl
    }
    createdAt
  }
}
''';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<String> selectedBrandIds = [];
  List<PostModel> posts = [];
  List<BrandModel?> brands = [];
  late final LoggedInUser _user = ref.watch(loggedInUserProvider);

  void _handleBrandFilter(BrandModel? brand, bool selected) {
    List<String> updatedIds = selectedBrandIds;

    // if selecting "My Brands", default to []
    if (brand == null) {
      updatedIds = [];
    } else {
      // if selecting a different brand, add to list
      if (selected && !selectedBrandIds.contains(brand.id)) {
        updatedIds.add(brand.id);
      }
      // if deselecting a brand, remove from list
      else if (!selected && selectedBrandIds.contains(brand.id)) {
        updatedIds.remove(brand.id);
      }
    }

    setState(() {
      selectedBrandIds = updatedIds;
    });
  }

  Future<List<PostModel>> _getPosts(GraphQLClient client) async {
    Map<String, dynamic> variables = {
      "options": {
        "sort": [
          {"createdAt": "DESC"}
        ]
      },
      "where": {}
    };

    if (selectedBrandIds.isNotEmpty) {
      variables['where']['inBrandCommunity'] = {"id_IN": selectedBrandIds};
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
                    brands = snapshot.data;
                  }
                  return ListView.separated(
                      padding: const EdgeInsets.all(5),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(width: 5);
                      },
                      itemCount: brands.length,
                      itemBuilder: (context, index) => BrandChip(
                            brand: brands[index],
                            selected: (index > 0
                                ? selectedBrandIds
                                    .contains((brands[index] as BrandModel).id)
                                : selectedBrandIds.isEmpty),
                            onSelection: _handleBrandFilter,
                          ));
                });
          }));
    }

    _buildPostCells() {
      return GraphQLConsumer(builder: (GraphQLClient client) {
        return FutureBuilder(
            future: _getPosts(client),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return const ErrorView();
              } else if (snapshot.hasData) {
                posts = snapshot.data;
                return PostListView(posts, (context, postId) => {});
              } else {
                return const Loading();
              }
            });
      });
    }

    return Column(children: [
      _buildBrandChips(),
      const SizedBox(height: 10),
      Expanded(child: _buildPostCells())
    ]);
  }
}
