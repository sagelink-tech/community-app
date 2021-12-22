import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/models/brand_model.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';

class BrandOverview extends StatelessWidget {
  final BrandModel brand;

  const BrandOverview(this.brand, {Key? key}) : super(key: key);

  // Navigation
  _goToAccount(BuildContext context, String userId) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("Mission", style: Theme.of(context).textTheme.headline4),
      Text(brand.description),
      Text("Causes", style: Theme.of(context).textTheme.headline4),
      Text(brand.description),
      Text("People", style: Theme.of(context).textTheme.headline4),
      Expanded(
          child: ListView(
              children: brand.employees
                  .map((e) => ListTile(
                        leading: ClickableAvatar(
                            avatarText: e.name[0],
                            avatarURL: e.accountPictureUrl),
                        title: Text(e.name),
                        subtitle: Text(e.jobTitle),
                        onTap: () => _goToAccount(context, e.id),
                      ))
                  .toList()))
    ]);
  }
}
