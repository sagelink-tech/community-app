import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/components/list_spacer.dart';
import 'package:sagelink_communities/models/brand_model.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';
import 'package:url_launcher/url_launcher.dart';

class BrandOverview extends StatelessWidget {
  final BrandModel brand;
  final bool shrinkWrap;
  final bool primary;

  const BrandOverview(this.brand,
      {this.shrinkWrap = false, this.primary = true, Key? key})
      : super(key: key);

  // Navigation
  _goToAccount(BuildContext context, String userId) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  Future<void> _launchURL(String url) async {
    if (!await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  // Builders
  Widget causesList(BuildContext context) {
    if (brand.causes.isEmpty) {
      return const SizedBox(height: 30);
    }
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: brand.causes.map((c) => Chip(label: Text(c.title))).toList(),
    );
  }

  Widget peopleList(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        primary: false,
        children: brand.employees
            .map((e) => ListTile(
                  leading: ClickableAvatar(
                      avatarText: e.name[0], avatarURL: e.accountPictureUrl),
                  title: Text(e.name),
                  subtitle: Text(e.jobTitle),
                  onTap: () => _goToAccount(context, e.id),
                ))
            .toList());
  }

  Widget externalLinks(BuildContext context) {
    return ListView(shrinkWrap: true, primary: false, children: [
      ListTile(
        title: Text(
          "Main Store",
          style: Theme.of(context).textTheme.headline6,
        ),
        onTap: () => {_launchURL(brand.website)},
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: shrinkWrap,
        primary: primary,
        padding: const EdgeInsets.all(10),
        children: [
          Text("People", style: Theme.of(context).textTheme.headline4),
          peopleList(context),
          Text("Mission", style: Theme.of(context).textTheme.headline4),
          Text(brand.description, style: Theme.of(context).textTheme.bodyLarge),
          const ListSpacer(),
          Text("Causes", style: Theme.of(context).textTheme.headline4),
          causesList(context),
          const ListSpacer(),
          Text("Links", style: Theme.of(context).textTheme.headline4),
          externalLinks(context),
        ]);
  }
}
