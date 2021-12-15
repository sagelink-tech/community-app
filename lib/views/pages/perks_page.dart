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
      "description":
          "This is a test perk for us to see what the visual aesthetic of the consumer application actually looks like. This is going to be a bit longer than necessary just so we can start testing around and whatever. Who knows what I'm actually going to end up writing - probably just some nonsense if I'm being honest. Ok I'm done.",
      "productId": "123",
      "productName": "Test Product",
      "price": 35.0,
      "imageUrls": <String>[
        "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcQeIJLT6aYwziw15ir4UcdBj_9jGZ9j3tTjgT_BugucHZht9POENS6JZ2VbKao&usqp=CAE",
        "https://cdn.shopify.com/s/files/1/1009/9408/products/greentruck-front_1200x.jpg?v=1603296118",
        "https://cdn.shopify.com/s/files/1/1009/9408/products/greentruck-front_1200x.jpg?v=1603296118"
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
