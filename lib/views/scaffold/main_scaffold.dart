import 'package:community_app/views/pages/account_page.dart';
import 'package:community_app/views/pages/brands_page.dart';
import 'package:community_app/views/pages/home_page.dart';
import 'package:community_app/views/pages/perks_page.dart';
import 'package:community_app/views/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_app/providers.dart';
import 'package:community_app/views/scaffold/nav_bar.dart';
import 'package:community_app/views/scaffold/nav_bar_mobile.dart';

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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            onPressed: () => _goToAccount(loggedInUser.userId),
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: pageOptions[_selectedIndex].body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.background),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
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
