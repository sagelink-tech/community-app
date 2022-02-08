import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/user_model.dart';

// ignore: constant_identifier_names
const String UPDATE_USER_MUTATION = '''
mutation Mutation(\$update: UserUpdateInput, \$where: UserWhere, \$connect: UserConnectInput, \$disconnect: UserDisconnectInput) {
  updateUsers(update: \$update, where: \$where, connect: \$connect, disconnect: \$disconnect) {
    users {
      id
    }
  }
}
''';

class UserService {
  final GraphQLClient client;
  final LoggedInUser authUser;

  const UserService({required this.client, required this.authUser});

  /////////////////////////////////////////////////////////////
  /// Removing users
  /////////////////////////////////////////////////////////////

  // TO DELETE A USER, SEND A REQUEST TO A QUEUE THAT WE WILL
  // PROCESS (DELETE ALL DATA)

  /////////////////////////////////////////////////////////////
  /// Manage members and team
  /////////////////////////////////////////////////////////////

  // Add a user to a community
  //TODO
  Future<bool> addUserToCommunity(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    return true;
  }

  // Remove a user from a community
  // This actually bans the user from the community
  Future<bool> banUserFromCommunity(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only ban users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "connect": {
        "bannedFromBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Remove a user from a community
  // This actually bans the user from the community
  //TODO
  Future<bool> unbanUserFromCommunity(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only ban users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "disconnect": {
        "bannedFromBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Change admin status
  // TODO
  Future<bool> changeAdminStatus(
      UserModel user, String brandId, Map<String, dynamic>? adminDetails,
      {OnMutationCompleted? onComplete}) async {
    if (adminDetails == null) {
      // disconnect as admin
    } else {
      // connect as admin
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Blocking and flagging users
  /////////////////////////////////////////////////////////////

  // Block a user
  Future<bool> blockUser(UserModel user,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "where": {"id": authUser.getUser().id},
      "connect": {
        "blockedUsers": {
          "where": {
            "node": {"id": user.id},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == authUser.getUser().id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Unblock a user
  Future<bool> unblockUser(UserModel user,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "where": {"id": authUser.getUser().id},
      "disconnect": {
        "blockedUsers": {
          "where": {
            "node": {"id": user.id},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == authUser.getUser().id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Unflag a user
  Future<bool> unflagUser(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only flag users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "disconnect": {
        "flaggedInBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Flag a user
  Future<bool> flagUser(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only flag users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "connect": {
        "flaggedInBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Update user data
  /////////////////////////////////////////////////////////////

  // Update user with update dictionary
  Future<bool> updateUser(UserModel user, Map<String, dynamic> updateData,
      {OnMutationCompleted? onComplete}) async {
    if (user.id != authUser.getUser().id) {
      return false;
    }

    Map<String, dynamic> variables = {
      "update": updateData,
      "where": {"id": user.id}
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success =
        (result.data != null && result.data!['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Creating users
  /////////////////////////////////////////////////////////////

  // This should be handled as a gcp cloud function on account creation
  // To "create a member" the user account must already exist, and then
  // the user is added to the community.

}
