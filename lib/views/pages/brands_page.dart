import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list.dart';
import 'package:community_app/views/pages/brand_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class BrandsPage extends ConsumerWidget {
  const BrandsPage({Key? key}) : super(key: key);

  void _handleBrandSelection(BuildContext context, String brandId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BrandHomepage(brandId: brandId)));
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<BrandModel> brands = [];

    return Query(
        options: QueryOptions(document: gql(getBrandsQuery)),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          brands = [];
          for (var b in result.data?['brands']) {
            brands.add(BrandModel.fromJson(b));
          }
          return BrandListView(brands, _handleBrandSelection);
        });
  }
}
