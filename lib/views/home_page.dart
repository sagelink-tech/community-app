import 'package:community_app/commands/get_brands_command.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:community_app/views/brand_list/brand_list.dart';
import 'package:community_app/views/brand_home_page.dart';
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

  void _handleBrandSelection(BuildContext context, String brandId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BrandHomepage(brandId: brandId)));
    return;
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
              onPressed: _isLoading ? null : _handleRefreshPressed,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : BrandListView(brands, _handleBrandSelection));
  }
}
