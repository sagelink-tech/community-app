import 'package:community_app/commands/get_brands_command.dart';
import 'package:community_app/commands/get_posts_command.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list.dart';
import 'package:community_app/views/brand_home_page.dart';
import 'package:community_app/views/account_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_model.dart';
import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  void _handleRefreshPressed() async {
    var currentUser = context.read<AppModel>().currentUser;
    if (_isLoading || currentUser == null) {
      return;
    }
    // Disable the RefreshBtn while the Command is running
    setState(() => _isLoading = true);
    // Run command

    await GetBrandsCommand().run(currentUser);

    // Re-enable refresh btn when command is done
    setState(() => _isLoading = false);
  }

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

  void _handlePostSelection(BuildContext context, String postId) {
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Bind to UserModel.userPosts
    var brands =
        context.select<UserModel, List<BrandModel>>((value) => value.brands);

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Text("My Brands"),
              Expanded(child: BrandListView(brands, _handleBrandSelection))
            ]),
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
