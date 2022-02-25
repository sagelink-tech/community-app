import 'package:sagelink_communities/ui/components/causes_chips.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'community_guidelines.dart';

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

  _showCommunityGuidelines(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) => FractionallySizedBox(
            heightFactor: 0.85,
            child:
                CommunityGuidelines(guidelineText: brand.communityGuidelines)));
  }

  Future<void> _launchURL(String url) async {
    try {
      !await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
      );
    } catch (e) {
      print(e);
      return;
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
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => ListTile(
              leading: ClickableAvatar(
                  avatarText: brand.employees[index].name[0],
                  avatarURL: brand.employees[index].accountPictureUrl),
              title: Text(brand.employees[index].name),
              subtitle: Text(brand.employees[index].jobTitle),
              onTap: () => _goToAccount(context, brand.employees[index].id),
            ),
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: brand.employees.length,
        shrinkWrap: true,
        primary: false);
  }

  Widget externalLinks(BuildContext context) {
    List<BrandLink> links = [
      BrandLink("store", "Full shop", brand.website),
      const BrandLink("guidelines", "Community Guidelines", null)
    ];
    links.addAll(brand.links);

    return ListView.separated(
        itemCount: links.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) => InkWell(
            child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  links[index].title,
                )),
            onTap: () => {
                  links[index].url != null
                      ? _launchURL(links[index].url!)
                      : _showCommunityGuidelines(context)
                }),
        shrinkWrap: true,
        primary: false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: shrinkWrap,
        primary: primary,
        padding: const EdgeInsets.all(10),
        children: [
          peopleList(context),
          Text("Causes", style: Theme.of(context).textTheme.headline4),
          CausesChips(causes: brand.causes),
          const ListSpacer(),
          Text("Mission", style: Theme.of(context).textTheme.headline4),
          Text(brand.description, style: Theme.of(context).textTheme.caption),
          const ListSpacer(),
          Text("Links", style: Theme.of(context).textTheme.headline4),
          externalLinks(context),
        ]);
  }
}
