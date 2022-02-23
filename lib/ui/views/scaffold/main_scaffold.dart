import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/views/admin_pages/go_to_admin_page.dart';
import 'package:sagelink_communities/ui/views/brands/brand_home_page.dart';
import 'package:sagelink_communities/ui/views/pages/brands_page.dart';
import 'package:sagelink_communities/ui/views/pages/home_page.dart';
import 'package:sagelink_communities/ui/views/pages/perks_page.dart';
import 'package:sagelink_communities/ui/views/pages/settings_page.dart';
import 'package:sagelink_communities/ui/views/perks/perk_view.dart';
import 'package:sagelink_communities/ui/views/posts/new_post_brand_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/views/posts/new_post_view.dart';
import 'package:sagelink_communities/ui/views/posts/post_view.dart';
import 'package:sagelink_communities/ui/views/scaffold/nav_bar.dart';
import 'package:sagelink_communities/ui/views/scaffold/nav_bar_mobile.dart';

typedef OnAction = void Function(BuildContext context);

class TabItem {
  String title;
  String tabText;
  Icon icon;
  Widget body;
  bool showFloatingAction;
  OnAction? onAction;
  Widget? scaffoldAction;
  Widget? leading;

  TabItem(this.title, this.tabText, this.icon, this.body,
      {this.showFloatingAction = true,
      this.onAction,
      this.scaffoldAction,
      this.leading});
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

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) => _handleMessage(message));
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'post') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  PostView(postId: message.data['postId'])));
    }
    if (message.data['type'] == 'perk') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  PerkView(perkId: message.data['perkId'])));
    }
    if (message.data['type'] == 'brand') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  BrandHomepage(brandId: message.data['brandId'])));
    }
  }

  List<TabItem> consumerPageOptions = [
    TabItem("", "Home", const Icon(Icons.home_outlined), const HomePage()),
    TabItem("Shop", "Shop", const Icon(Icons.shopping_cart_outlined),
        const PerksPage()),
    TabItem("My Brands", "Brands", const Icon(Icons.collections_outlined),
        const BrandsPage(),
        showFloatingAction: false),
    TabItem("My Settings", "Settings", const Icon(Icons.settings_outlined),
        const SettingsPage(),
        showFloatingAction: false)
  ];

  List<TabItem> _pageOptions() {
    var _pages = [
      TabItem("", "Home", const Icon(Icons.home_outlined), const HomePage()),
      TabItem("Shop", "Shop", const Icon(Icons.shopping_cart_outlined),
          const PerksPage()),
      TabItem("My Brands", "Brands", const Icon(Icons.collections_outlined),
          const BrandsPage(),
          showFloatingAction: false),
      TabItem("Messages", "Messages", const Icon(Icons.mail_outline),
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

    void _goToSettings() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageOptions()[_selectedIndex].title),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          ClickableAvatar(
            avatarText: loggedInUser.getUser().name[0],
            avatarURL: loggedInUser.getUser().accountPictureUrl,
            radius: 20,
            padding: const EdgeInsets.all(10),
            onTap: _goToSettings,
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
                        builder: (context) =>
                            loggedInUser.getUser().brands.length == 1
                                ? NewPostPage(
                                    brandId:
                                        loggedInUser.getUser().brands[0].id,
                                    onCompleted: () => {})
                                : const NewPostBrandSelection()));
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
