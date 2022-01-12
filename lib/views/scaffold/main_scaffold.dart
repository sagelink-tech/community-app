import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/views/admin_pages/go_to_admin_page.dart';
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

typedef OnClickCallback = void Function();

class TabItem {
  String title;
  String tabText;
  Icon icon;
  Widget body;
  bool showFloatingAction;

  TabItem(this.title, this.tabText, this.icon, this.body,
      {this.showFloatingAction = true});
}

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;
  late List<TabItem> pages;

  late final loggedInUser = ref.watch(loggedInUserProvider);

  @override
  void initState() {
    super.initState();
  }

  List<TabItem> consumerPageOptions = [
    TabItem("", "Home", const Icon(Icons.home_outlined), const HomePage()),
    TabItem("My Perks", "Perks", const Icon(Icons.shopping_cart_outlined),
        const PerksPage()),
    TabItem("My Brands", "Brands", const Icon(Icons.casino_outlined),
        const BrandsPage(),
        showFloatingAction: false),
    TabItem("My Settings", "Settings", const Icon(Icons.settings_outlined),
        const SettingsPage(),
        showFloatingAction: false)
  ];

  List<TabItem> _pageOptions() {
    var _pages = [
      TabItem("", "Home", const Icon(Icons.home_outlined), const HomePage()),
      TabItem("My Perks", "Perks", const Icon(Icons.shopping_cart_outlined),
          const PerksPage()),
      TabItem("My Brands", "Brands", const Icon(Icons.casino_outlined),
          const BrandsPage(),
          showFloatingAction: false),
      TabItem("My Settings", "Settings", const Icon(Icons.settings_outlined),
          const SettingsPage(),
          showFloatingAction: false)
    ];

    if (loggedInUser.isAdmin) {
      _pages.add(TabItem(
          "",
          "Admin",
          const Icon(Icons.admin_panel_settings_outlined),
          const GoToAdminPage(),
          showFloatingAction: false));
    }
    return _pages;
  }

  @override
  Widget build(BuildContext context) {
    // Check for device size
    bool showSmallScreen = MediaQuery.of(context).size.shortestSide <= 550;

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
        title: Text(_pageOptions()[_selectedIndex].title),
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
      body: _pageOptions()[_selectedIndex].body,
      floatingActionButton: _pageOptions()[_selectedIndex].showFloatingAction
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
      drawer: showSmallScreen
          ? null
          : HomeNavDrawerMenu(
              onSelect: _handlePageSelection,
              tabItems: _pageOptions(),
              selectedIndex: _selectedIndex),
      bottomNavigationBar: showSmallScreen
          ? HomeNavTabMenu(
              onSelect: _handlePageSelection, tabItems: _pageOptions())
          : null,
    );
  }
}
