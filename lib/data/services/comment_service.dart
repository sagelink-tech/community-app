import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/models/comment_model.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:sagelink_communities/data/models/post_model.dart';

// ignore: constant_identifier_names
const String REMOVE_COMMENT_MUTATION = '''
mutation Mutation(\$delete: CommentDeleteInput, \$where: CommentWhere) {
  deleteComments(delete: \$delete, where: \$where) {
    nodesDeleted
  }
}
''';

// ignore: constant_identifier_names
const String UPDATE_COMMENT_MUTATION = '''
mutation Mutation(\$update: CommentUpdateInput, \$where: CommentWhere, \$connect: CommentConnectInput) {
  updateComments(update: \$update, where: \$where, connect: \$connect) {
    comments {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String CREATE_COMMENT_MUTATION = '''
mutation Mutation(\$input: [CommentCreateInput!]!) {
  createComments(input: \$input) {
    comments {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String REACT_TO_COMMENT_MUTATION = '''
''';

class CommentService {
  final GraphQLClient client;
  final LoggedInUser user;

  const CommentService({required this.client, required this.user});

  /////////////////////////////////////////////////////////////
  /// Removing comments
  /////////////////////////////////////////////////////////////

  // Remove a comment and it's thread
  Future<bool> removeComment(CommentModel comment, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (comment.creator.id != user.getUser().id &&
        brandId != user.adminBrandId) {
      return false;
    }

    Map<String, dynamic> variables = {
      "delete": {
        "replies": [
          {
            "where": {
              "node": {
                "onComment": {"id": comment.id}
              }
            }
          }
        ]
      },
      "where": {"id": comment.id}
    };

    MutationOptions options = MutationOptions(
        document: gql(REMOVE_COMMENT_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['deleteComments']['nodesDeleted'] > 0);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Updating comments
  /////////////////////////////////////////////////////////////

  // React to a comment
  Future<bool> reactToComment(CommentModel comment, String reaction) async {
    return true;
  }

  // Flag a comment
  Future<bool> flagComment(CommentModel comment,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "where": {"id": comment.id},
      "connect": {
        "flaggedBy": {
          "where": {
            "node": {"id": user.getUser().id}
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_COMMENT_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateComments']['comments'][0]['id'] == comment.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Update comment with body text
  Future<bool> updateComment(CommentModel comment, String newBody,
      {OnMutationCompleted? onComplete}) async {
    if (comment.creator.id != user.getUser().id) {
      return false;
    }

    Map<String, dynamic> variables = {
      "update": {"body": newBody},
      "where": {"id": comment.id}
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_COMMENT_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateComments']['comments'][0]['id'] == comment.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Creating comments
  /////////////////////////////////////////////////////////////

  // Reply to a comment
  Future<bool> replyToCommentWithID(String commentId, String replyBody,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "input": [
        {
          "body": replyBody,
          "createdBy": {
            "connect": {
              "where": {
                "node": {"id": user.getUser().id}
              }
            }
          },
          "onComment": {
            "connect": {
              "where": {
                "node": {"id": commentId}
              }
            }
          }
        }
      ]
    };

    MutationOptions options = MutationOptions(
        document: gql(CREATE_COMMENT_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        (result.data!['createComments']['comments'] as List).length == 1);
    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Comment on a post
  Future<bool> commentOnPostWithID(String postId, String commentBody,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "input": [
        {
          "body": commentBody,
          "createdBy": {
            "connect": {
              "where": {
                "node": {"id": user.getUser().id}
              }
            }
          },
          "onPost": {
            "connect": {
              "where": {
                "node": {"id": postId}
              }
            }
          }
        }
      ]
    };

    MutationOptions options = MutationOptions(
        document: gql(CREATE_COMMENT_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        (result.data!['createComments']['comments'] as List).length == 1);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Comment on a perk
  Future<bool> commentOnPerkWithID(String perkId, String commentBody,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "input": [
        {
          "body": commentBody,
          "createdBy": {
            "connect": {
              "where": {
                "node": {"id": user.getUser().id}
              }
            }
          },
          "onPerk": {
            "connect": {
              "where": {
                "node": {"id": perkId}
              }
            }
          }
        }
      ]
    };

    MutationOptions options = MutationOptions(
        document: gql(CREATE_COMMENT_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        (result.data!['createComments']['comments'] as List).length == 1);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }
}
