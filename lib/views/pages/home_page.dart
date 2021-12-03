import 'package:community_app/components/brand_chip.dart';
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

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  void _handleBrandSelection(
      BuildContext context, String? brandId, bool selected) {
    if (brandId != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BrandHomepage(brandId: brandId)));
    }
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<BrandModel?> brands = [];

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
          brands = [null];
          for (var b in result.data?['brands']) {
            brands.add(BrandModel.fromJson(b));
          }
          return ListView(
            scrollDirection: Axis.vertical,
            children: [
              SizedBox(
                height: 50,
                child: ListView.separated(
                    padding: const EdgeInsets.all(5),
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 5);
                    },
                    itemCount: brands.length,
                    itemBuilder: (context, index) => BrandChip(
                        brand: brands[index],
                        onSelection: _handleBrandSelection)),
              ),
              const Text('Homepage'),
            ],
          );
        });
  }
}
