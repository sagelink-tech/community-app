import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list.dart';
import 'package:community_app/views/posts/new_post_view.dart';
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

class NewPostBrandSelection extends StatefulWidget {
  const NewPostBrandSelection({Key? key}) : super(key: key);

  @override
  _NewPostBrandSelectionState createState() => _NewPostBrandSelectionState();
}

class _NewPostBrandSelectionState extends State<NewPostBrandSelection> {
  List<BrandModel> brands = [];

  void _handleBrandSelection(BuildContext context, String brandId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewPostPage(
                brandId: brandId, onCompleted: () => _popBack(context))));
    return;
  }

  void _popBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<List<BrandModel?>> _getBrands(GraphQLClient client) async {
    List<BrandModel> _brands = [];
    QueryResult result =
        await client.query(QueryOptions(document: gql(getBrandsQuery)));

    if (result.data != null && (result.data!['brands'] as List).isNotEmpty) {
      List brandJsons = result.data!['brands'] as List;
      _brands += brandJsons.map((e) => BrandModel.fromJson(e)).toList();
    }
    return _brands;
  }

  Widget _buildBrandSelection(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return FutureBuilder(
          future: _getBrands(client),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              brands = snapshot.data;
            }
            return BrandListView(brands, _handleBrandSelection);
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor, elevation: 0),
        body: Column(children: [
          Center(
              child: Text(
            "What brand would you like to create a post for?",
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          )),
          Expanded(child: _buildBrandSelection(context))
        ]));
  }
}
