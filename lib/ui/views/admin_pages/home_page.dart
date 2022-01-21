import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/views/posts/post_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getPostsQuery = '''
query GetPostsQuery(\$options: PostOptions, \$where: PostWhere) {
  posts(options: \$options, where: \$where) {
    id
    title
    type
    body
    linkUrl
    images
    createdBy {
      id
      name
      accountPictureUrl
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

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  List<PostModel> posts = [];
  late final LoggedInUser loggedInUser = ref.watch(loggedInUserProvider);

  Future<List<PostModel>> _getPosts(
      GraphQLClient client, String brandId) async {
    Map<String, dynamic> variables = {
      "options": {
        "sort": [
          {"createdAt": "DESC"}
        ]
      },
      "where": {
        "inBrandCommunity": {"id": brandId}
      }
    };

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

  @override
  Widget build(BuildContext context) {
    _buildPostCells() {
      return GraphQLConsumer(builder: (GraphQLClient client) {
        return FutureBuilder(
            future: _getPosts(client, loggedInUser.adminBrandId!),
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
      const SizedBox(height: 10),
      Expanded(child: _buildPostCells())
    ]);
  }
}
