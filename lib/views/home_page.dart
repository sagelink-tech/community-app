import 'package:community_app/commands/get_brands_command.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../commands/refresh_posts_command.dart';
import '../models/app_model.dart';
import '../models/user_model.dart';

class HomePage extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    // Bind to UserModel.userPosts
    var brands =
        context.select<UserModel, List<BrandModel>>((value) => value.brands);

    // Render list of widgets
    var listWidgets = brands.map((brand) => Text(brand.name)).toList();
    var listBuilder = ListView.builder(
        itemCount: brands.length,
        cacheExtent: 20,
        controller: ScrollController(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (context, index) => BrandTile(index));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Sagelink'),
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(primary: Colors.white),
              onPressed: _isLoading ? null : _handleRefreshPressed,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        body: listBuilder);
  }
}

class BrandTile extends StatelessWidget {
  final int itemNo;

  const BrandTile(this.itemNo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserModel>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(user.brands[itemNo].name[0])),
        title: Text(
          user.brands[itemNo].name,
          key: Key('text_$itemNo'),
        ),
        trailing: IconButton(
          key: Key('icon_$itemNo'),
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {},
        ),
      ),
    );
  }
}
