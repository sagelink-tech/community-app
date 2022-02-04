import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/post_model.dart';

// ignore: constant_identifier_names
const String REMOVE_POST_MUTATION = '''
mutation Mutation(\$delete: PostDeleteInput, \$where: PostWhere) {
  deletePosts(delete: \$delete, where: \$where) {
    nodesDeleted
  }
}
''';

// ignore: constant_identifier_names
const String UPDATE_POST_MUTATION = '''
mutation Mutation(\$update: PostUpdateInput, \$where: PostWhere, \$connect: PostConnectInput) {
  updatePosts(update: \$update, where: \$where, connect: \$connect) {
    posts {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String CREATE_POST_MUTATION = '''
mutation Mutation(\$input: [PostCreateInput!]!) {
  createPosts(input: \$input) {
    posts {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String REACT_TO_POST_MUTATION = '''
''';

class PostService {
  final GraphQLClient client;
  final LoggedInUser user;

  const PostService({required this.client, required this.user});

  /////////////////////////////////////////////////////////////
  /// Removing posts
  /////////////////////////////////////////////////////////////

  // Remove a comment and it's thread
  Future<bool> removePost(PostModel post,
      {OnMutationCompleted? onComplete}) async {
    if (post.creator.id != user.getUser().id &&
        post.brand.id != user.adminBrandId) {
      return false;
    }

    Map<String, dynamic> variables = {
      "delete": {
        "comments": [
          {
            "where": {
              "node": {
                "onPost": {"id": post.id}
              }
            },
            "delete": {
              "replies": [
                {"where": {}}
              ]
            }
          }
        ]
      },
      "where": {"id": post.id}
    };

    MutationOptions options = MutationOptions(
        document: gql(REMOVE_POST_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['deletePosts']['nodesDeleted'] > 0);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Updating posts
  /////////////////////////////////////////////////////////////

  // React to a comment
  Future<bool> reactToPost(PostModel post, String reaction) async {
    return true;
  }

  // Flag a comment
  Future<bool> flagPost(PostModel post,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "where": {"id": post.id},
      "connect": {
        "flaggedBy": {
          "where": {
            "node": {"id": user.getUser().id}
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_POST_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updatePosts']['posts'][0]['id'] == post.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Update post with update dictionary
  Future<bool> updatePost(PostModel post, Map<String, dynamic> updateData,
      {OnMutationCompleted? onComplete}) async {
    if (post.creator.id != user.getUser().id) {
      return false;
    }

    Map<String, dynamic> variables = {
      "update": updateData,
      "where": {"id": post.id}
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_POST_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success =
        (result.data != null && result.data!['posts'][0]['id'] == post.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Creating posts
  /////////////////////////////////////////////////////////////

}
