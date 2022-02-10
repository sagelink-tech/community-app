import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/ui/views/brands/brand_list.dart';
import 'package:sagelink_communities/ui/views/brands/brand_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/users/accept_invite_page.dart';

String getBrandsQuery = '''
query Brands {
  brands {
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

  void _handleInviteButtonClick(BuildContext bc, VoidCallback? refetch) {
    showModalBottomSheet(
        context: bc,
        builder: (BuildContext context) => AcceptInvitePage(onComplete: () {
              if (refetch != null) {
                refetch();
              }
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<BrandModel> brands = [];

    return Query(
        options: QueryOptions(document: gql(getBrandsQuery)),
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
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              BrandListView(brands, _handleBrandSelection),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.secondary,
                          onPrimary: Theme.of(context).colorScheme.onError,
                          minimumSize: const Size.fromHeight(48)),
                      onPressed: () =>
                          _handleInviteButtonClick(context, refetch),
                      child: const Text('Accept Community Invite'))),
            ],
          );
        });
  }
}
