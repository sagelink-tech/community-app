import 'package:community_app/components/brand_chip.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:community_app/models/perk_model.dart';
import 'package:community_app/views/perks/perk_list.dart';
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
    await Future.delayed(const Duration(milliseconds: 300));
    var perkJson = {
      "id": "123",
      "title": "Test Perk",
      "productId": "123",
      "productName": "Test Product",
      "price": 350.0,
      "imageUrls": <String>[
        "https://slimages.macysassets.com/is/image/MCY/products/4/optimized/8278534_fpx.tif?op_sharpen=1&wid=700&hei=855&fit=fit,1"
      ],
      "currency": Currencies.usd,
      "type": PerkType.productDrop,
      "startDate": DateTime(2022, 1, 1, 0, 0, 0).toString(),
      "endDate": DateTime(2022, 1, 2, 0, 0, 0).toString(),
      "commentsAggregate": {"count": 0},
      "inBrandCommunity": BrandModel().toJson(),
      "createdBy": UserModel().toJson(),
    };
    return [
      PerkModel.fromJson(perkJson),
      PerkModel.fromJson(perkJson),
      PerkModel.fromJson(perkJson),
      PerkModel.fromJson(perkJson),
      PerkModel.fromJson(perkJson),
      PerkModel.fromJson(perkJson)
    ];
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
              if (snapshot.hasData) {
                perks = snapshot.data;
              }
              return PerkListView(perks, (context, perkId) => {});
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
