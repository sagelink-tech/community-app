import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/brand_chip.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/ui/views/posts/post_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
      queryUserHasBlocked
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
  late final userBrands = ref.watch(brandsProvider);
  late final client = ref.watch(gqlClientProvider).value;

  late List<String> selectedBrandIds =
      brands.where((e) => e != null).map((e) => e!.id).toList();
  List<PostModel> posts = [];
  late List<BrandModel?> brands =
      userBrands.length > 1 ? [null, ...userBrands] : userBrands;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      _getPosts();
    });
  }

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

  QueryOptions qOptions() {
    Map<String, dynamic> variables = {
      "options": {
        "sort": [
          {"createdAt": "DESC"}
        ],
      },
      "where": {}
    };
    if (selectedBrandIds.isNotEmpty) {
      variables['where']['inBrandCommunity'] = {"id_IN": selectedBrandIds};
    }
    return QueryOptions(
      document: gql(getPostsQuery),
      variables: variables,
    );
  }

  Future<void> _getPosts() async {
    setState(() {
      _isFetching = true;
      posts = [];
    });

    QueryResult result = await client.query(qOptions());

    List<PostModel> _posts = [];

    if (result.data != null && (result.data!['posts'] as List).isNotEmpty) {
      List postJsons = result.data!['posts'] as List;
      _posts = postJsons.map((e) => PostModel.fromJson(e)).toList();
      _posts.removeWhere(
          (p) => p.isFlaggedByUser || p.creator.queryUserHasBlocked);
    }
    setState(() {
      _isFetching = false;
      posts = _posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildBrandChips() {
      return SizedBox(
          height: 50,
          child: ListView.separated(
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
                  )));
    }

    _buildPostCells() {
      return RefreshIndicator(
        child: _isFetching
            ? const Loading()
            : PostListView(posts, (context, postId) => {}),
        onRefresh: _getPosts,
      );
    }

    return Column(
        children: brands.length > 1
            ? [
                _buildBrandChips(),
                const SizedBox(height: 10),
                Expanded(child: _buildPostCells())
              ]
            : [Expanded(child: _buildPostCells())]);
  }
}
