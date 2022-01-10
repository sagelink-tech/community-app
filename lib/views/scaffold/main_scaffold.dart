import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/models/logged_in_user.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';
import 'package:sagelink_communities/views/pages/brands_page.dart';
import 'package:sagelink_communities/views/pages/home_page.dart';
import 'package:sagelink_communities/views/pages/perks_page.dart';
import 'package:sagelink_communities/views/pages/settings_page.dart';
import 'package:sagelink_communities/views/posts/new_post_brand_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:sagelink_communities/views/scaffold/nav_bar.dart';
import 'package:sagelink_communities/views/scaffold/nav_bar_mobile.dart';

class TabItem {
  String title;
  String tabText;
  Icon icon;
  Widget body;

  TabItem(this.title, this.tabText, this.icon, this.body);
}

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    //final loggedInUser = ref.read(loggedInUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Check for device size
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    bool showSmallScreenView = queryData.size.width < 600;

    final loggedInUser = ref.watch(loggedInUserProvider);

    // Navigation Options
    final List<TabItem> pageOptions = [
      TabItem("", "Home", const Icon(Icons.home_outlined), const HomePage()),
      TabItem("My Perks", "Perks", const Icon(Icons.shopping_cart_outlined),
          const PerksPage()),
      TabItem("My Brands", "Brands", const Icon(Icons.casino_outlined),
          const BrandsPage()),
      TabItem("My Settings", "Settings", const Icon(Icons.settings_outlined),
          const SettingsPage())
    ];

    void _handlePageSelection(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    void _goToAccount(String userId) async {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageOptions[_selectedIndex].title),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {},
          // ),
          ClickableAvatar(
            avatarText: loggedInUser.getUser().name[0],
            avatarURL: loggedInUser.getUser().accountPictureUrl,
            radius: 20,
            padding: const EdgeInsets.all(10),
            onTap: () => _goToAccount(loggedInUser.getUser().id),
          )
        ],
      ),
      body: pageOptions[_selectedIndex].body,
      floatingActionButton: _selectedIndex != 3
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewPostBrandSelection()));
              },
              child: Icon(Icons.add,
                  color: Theme.of(context).colorScheme.background),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            )
          : null,
      drawer: showSmallScreenView
          ? null
          : HomeNavDrawerMenu(
              onSelect: _handlePageSelection,
              tabItems: pageOptions,
              selectedIndex: _selectedIndex),
      bottomNavigationBar: !showSmallScreenView
          ? null
          : HomeNavTabMenu(
              onSelect: _handlePageSelection, tabItems: pageOptions),
    );
  }
}
