import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list.dart';
import 'package:community_app/views/brand_home_page.dart';
import 'package:community_app/views/account_page.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  void _goToAccount() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const AccountPage(userId: "001")));
  }

  void _handleBrandSelection(BuildContext context, String brandId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BrandHomepage(brandId: brandId)));
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<BrandModel> brands = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sagelink'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _goToAccount,
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountPage(userId: "001")));
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
        ]),
      ),
    );
  }
}
