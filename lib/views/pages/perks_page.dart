import 'package:sagelink_communities/components/brand_chip.dart';
import 'package:sagelink_communities/components/error_view.dart';
import 'package:sagelink_communities/components/loading.dart';
import 'package:sagelink_communities/models/brand_model.dart';
import 'package:sagelink_communities/models/perk_model.dart';
import 'package:sagelink_communities/views/perks/perk_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getBrandsQuery = '''
query Brands {
  brands {
    name
    shopifyToken
    mainColor
    logoUrl
    id
  }
}
''';

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

class PerksPage extends StatefulWidget {
  const PerksPage({Key? key}) : super(key: key);

  static const routeName = '/perks';

  @override
  _PerksPageState createState() => _PerksPageState();
}

class _PerksPageState extends State<PerksPage> {
  List<String> selectedBrandIds = [];
  List<BrandModel?> brands = [];
  List<PerkModel> perks = [];

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

  Future<List<PerkModel>> _getPerks(GraphQLClient client) async {
    Map<String, dynamic> variables = {
      "options": {
        "sort": [
          {"createdAt": "DESC"}
        ]
      }
    };

    if (selectedBrandIds.isNotEmpty) {
      variables['where'] = {
        "inBrandCommunityConnection": {
          "node": {"id_IN": selectedBrandIds}
        }
      };
    }

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

    _buildPerkCells() {
      return GraphQLConsumer(builder: (GraphQLClient client) {
        return FutureBuilder(
            future: _getPerks(client),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return const ErrorView();
              } else if (snapshot.hasData) {
                perks = snapshot.data;
                return PerkListView(perks, (context, perkId) => {});
              } else {
                return const Loading();
              }
            });
      });
    }

    return Column(children: [
      _buildBrandChips(),
      const SizedBox(height: 10),
      Expanded(child: _buildPerkCells())
    ]);
  }
}
