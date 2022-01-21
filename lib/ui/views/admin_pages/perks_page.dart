import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/views/perks/perk_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getPerksQuery = '''
query GetPerksQuery(\$options: PerkOptions, \$where: PerkWhere) {
  perks(options: \$options, where: \$where) {
    id
    title
    type
    description
    imageUrls
    productName
    productId
    price
    createdAt
    startDate
    endDate
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
  }
}
''';

class AdminPerksPage extends ConsumerStatefulWidget {
  const AdminPerksPage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _AdminPerksPageState createState() => _AdminPerksPageState();
}

class _AdminPerksPageState extends ConsumerState<AdminPerksPage> {
  List<PerkModel> perks = [];
  late final LoggedInUser loggedInUser = ref.watch(loggedInUserProvider);

  Future<List<PerkModel>> _getPerks(
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
      document: gql(getPerksQuery),
      variables: variables,
    ));

    if (result.data != null && (result.data!['perks'] as List).isNotEmpty) {
      List perkJsons = result.data!['perks'] as List;
      return perkJsons.map((e) => PerkModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    _buildPerkCells() {
      return GraphQLConsumer(builder: (GraphQLClient client) {
        return FutureBuilder(
            future: _getPerks(client, loggedInUser.adminBrandId!),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return const ErrorView();
              } else if (snapshot.hasData) {
                perks = snapshot.data;
                return PerkListView(perks, (context, postId) => {});
              } else {
                return const Loading();
              }
            });
      });
    }

    return Column(children: [
      const SizedBox(height: 10),
      Expanded(child: _buildPerkCells())
    ]);
  }
}
