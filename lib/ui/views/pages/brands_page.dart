import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/ui/views/brands/brand_list.dart';
import 'package:sagelink_communities/ui/views/brands/brand_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getBrandsQuery = '''
query Brands(\$where: BrandWhere) {
  brands(where: \$where) {
    name
    shopifyToken
    mainColor
    logoUrl
    id
    employeesConnection {
      totalCount
    }
    membersConnection {
      totalCount
    }
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
    List<String> brandIds = ref.watch(brandsProvider).map((e) => e.id).toList();
    List<BrandModel> brands = [];

    return Query(
        options: QueryOptions(document: gql(getBrandsQuery), variables: {
          "where": {"id_IN": brandIds}
        }),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return const ErrorView();
          }
          if (result.isLoading) {
            return const Loading();
          }
          brands = [];
          for (var b in result.data?['brands']) {
            brands.add(BrandModel.fromJson(b));
          }
          return BrandListView(
            [...brands, null],
            _handleBrandSelection,
            onNewSelected: refetch,
          );
          ;
        });
  }
}
