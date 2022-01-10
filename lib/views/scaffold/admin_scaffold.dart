import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/components/empty_result.dart';
import 'package:sagelink_communities/views/admin_pages/go_to_admin_page.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';
import 'package:sagelink_communities/views/pages/home_page.dart';
import 'package:sagelink_communities/views/pages/settings_page.dart';
import 'package:sagelink_communities/views/posts/new_post_brand_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:sagelink_communities/views/scaffold/main_scaffold.dart';
import 'package:sagelink_communities/views/scaffold/nav_bar.dart';
import 'package:sagelink_communities/views/scaffold/nav_bar_mobile.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  const AdminScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<AdminScaffold> {
  int _selectedIndex = 0;
  late List<TabItem> pages;

  @override
  void initState() {
    super.initState();
    //final loggedInUser = ref.read(loggedInUserProvider);
  }

  List<TabItem> _pageOptions(bool isMobile) {
    var _pages = [
      TabItem("", "Home", const Icon(Icons.home_outlined), const HomePage()),
      TabItem("Members", "Members", const Icon(Icons.people_outline),
          const EmptyResult(text: "Members")),
      TabItem(
          "Conversations",
          "Conversations",
          const Icon(Icons.forum_outlined),
          const EmptyResult(text: "Conversations")),
      TabItem("Messages", "Messages", const Icon(Icons.chat_bubble_outlined),
          const EmptyResult(text: "Messages")),
      TabItem("Perks", "Perks", const Icon(Icons.shopping_cart_outlined),
          const EmptyResult(text: "Perks")),
      TabItem("Team", "Team", const Icon(Icons.groups_outlined),
          const EmptyResult(text: "Team")),
      TabItem("Brand", "Brand", const Icon(Icons.casino_outlined),
          const EmptyResult(text: "Brand")),
      TabItem("Settings", "Settings", const Icon(Icons.settings_outlined),
          const SettingsPage()),
    ];

    if (isMobile) {
      _pages.add(TabItem("Main", "Main",
          const Icon(Icons.transit_enterexit_outlined), const GoToAdminPage()));
    }

    return _pages;
  }

  @override
  Widget build(BuildContext context) {
    // Check for device size
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    bool showSmallScreenView = queryData.size.width < 600;

    final loggedInUser = ref.watch(loggedInUserProvider);

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
        title: Text(_pageOptions(showSmallScreenView)[_selectedIndex].title),
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
      body: _pageOptions(showSmallScreenView)[_selectedIndex].body,
      floatingActionButton: _pageOptions(showSmallScreenView)[_selectedIndex]
              .showFloatingAction
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
      drawer: HomeNavDrawerMenu(
          onSelect: _handlePageSelection,
          tabItems: _pageOptions(showSmallScreenView),
          selectedIndex: _selectedIndex),
    );
  }
}
