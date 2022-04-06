import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:sagelink_communities/data/models/post_model.dart';

// ignore: constant_identifier_names
const String REMOVE_PERK_MUTATION = '''
mutation Mutation(\$delete: PerkDeleteInput, \$where: PerkWhere) {
  deletePerks(delete: \$delete, where: \$where) {
    nodesDeleted
  }
}
''';

// ignore: constant_identifier_names
const String UPDATE_PERK_MUTATION = '''
mutation Mutation(\$update: PerkUpdateInput, \$where: PerkWhere, \$connect: PerkConnectInput) {
  updatePerks(update: \$update, where: \$where, connect: \$connect) {
    perks {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String CREATE_PERK_MUTATION = '''
mutation Mutation(\$input: [PerkCreateInput!]!) {
  createPerks(input: \$input) {
    perks {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String REACT_TO_PERK_MUTATION = '''
''';

class PerkService {
  final GraphQLClient client;
  final LoggedInUser user;
  final FirebaseAnalytics analytics;

  const PerkService(
      {required this.client, required this.user, required this.analytics});

  /////////////////////////////////////////////////////////////
  /// Removing perks
  /////////////////////////////////////////////////////////////

  // Remove a perk and it's comments
  Future<bool> removePerk(PerkModel perk,
      {OnMutationCompleted? onComplete}) async {
    if (perk.brand.id != user.adminBrandId) {
      return false;
    }

    Map<String, dynamic> variables = {
      "delete": {
        "comments": [
          {
            "where": {
              "node": {
                "onPerk": {"id": perk.id}
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
      "where": {"id": perk.id}
    };

    MutationOptions options = MutationOptions(
        document: gql(REMOVE_PERK_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);

    bool success = (!result.hasException &&
        result.data != null &&
        result.data!['deletePerks']['nodesDeleted'] > 0);

    analytics.logEvent(name: "remove_perk", parameters: {
      "status": success,
      "perkId": perk.id,
      "removedBy": user.getUser().firebaseId
    });
    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return success;
  }

  /////////////////////////////////////////////////////////////
  /// Updating perks
  /////////////////////////////////////////////////////////////

  // Update perk with update dictionary
  Future<bool> updatePerk(PerkModel perk, Map<String, dynamic> updateData,
      {OnMutationCompleted? onComplete}) async {
    if (perk.brand.id != user.adminBrandId) {
      return false;
    }

    Map<String, dynamic> variables = {
      "update": updateData,
      "where": {"id": perk.id}
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_PERK_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);

    bool success = (!result.hasException &&
        result.data != null &&
        result.data!['updatePerks']['perks'][0]['id'] == perk.id);

    analytics.logEvent(name: "update_perk", parameters: {
      "status": success,
      "perkId": perk.id,
    });

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return success;
  }
}
