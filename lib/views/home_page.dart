import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list.dart';
import 'package:community_app/views/brand_home_page.dart';
import 'package:community_app/views/account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../providers.dart';

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

  void _goToAccount(BuildContext context, String userId) async {
    print(userId);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

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

    final loggedInUser = ref.watch(loggedInUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sagelink'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            onPressed: () => _goToAccount(context, loggedInUser.userId),
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Query(
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
          }),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Test"),
            accountEmail: const Text("test@test.com"),
            decoration: const BoxDecoration(color: Colors.blueGrey),
            onDetailsPressed: () {
              Navigator.pop(context);
              _goToAccount(context, loggedInUser.userId);
            },
          ),
          ListTile(
            title: const Text('Latest'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Brands'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Shop'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              ref.read(loggedInUserProvider.notifier).logout();
            },
          ),
        ]),
      ),
    );
  }
}
