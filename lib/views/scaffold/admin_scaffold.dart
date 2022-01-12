import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/components/empty_result.dart';
import 'package:sagelink_communities/components/page_scaffold.dart';
import 'package:sagelink_communities/components/split_view.dart';
import 'package:sagelink_communities/views/admin_pages/go_to_admin_page.dart';
import 'package:sagelink_communities/views/admin_pages/members_page.dart';
import 'package:sagelink_communities/views/admin_pages/team_page.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';
import 'package:sagelink_communities/views/pages/home_page.dart';
import 'package:sagelink_communities/views/pages/settings_page.dart';
import 'package:sagelink_communities/views/posts/new_post_brand_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:sagelink_communities/views/scaffold/main_scaffold.dart';

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

  List<TabItem> _pageOptions() {
    var _pages = [
      TabItem("", "Home", const Icon(Icons.home_outlined), const HomePage()),
      TabItem("Members", "Members", const Icon(Icons.people_outline),
          const MembersPage(),
          showFloatingAction: false),
      TabItem(
          "Conversations",
          "Conversations",
          const Icon(Icons.forum_outlined),
          const EmptyResult(text: "Conversations")),
      TabItem("Messages", "Messages", const Icon(Icons.chat_bubble_outlined),
          const EmptyResult(text: "Messages")),
      TabItem("Perks", "Perks", const Icon(Icons.shopping_cart_outlined),
          const EmptyResult(text: "Perks")),
      TabItem(
          "Team", "Team", const Icon(Icons.groups_outlined), const TeamPage(),
          showFloatingAction: false),
      TabItem("Brand", "Brand", const Icon(Icons.casino_outlined),
          const EmptyResult(text: "Brand")),
      TabItem("Settings", "Settings", const Icon(Icons.settings_outlined),
          const SettingsPage(),
          showFloatingAction: false),
      TabItem("", "Main", const Icon(Icons.transit_enterexit_outlined),
          const GoToAdminPage(),
          showFloatingAction: false)
    ];
    return _pages;
  }

  @override
  Widget build(BuildContext context) {
    // Check for device size
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    bool showSmallScreenView = smallestDimension < 550;

    final loggedInUser = ref.watch(loggedInUserProvider);

    void _handlePageSelection(int index) {
      setState(() {
        _selectedIndex = index;
      });
      if (showSmallScreenView) {
        Navigator.pop(context);
      }
    }

    void _goToAccount(String userId) async {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
    }

    Widget _buildDrawer() {
      return Container(
          color: Theme.of(context).primaryColor,
          width: 250,
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  elevation: 1,
                  title: Text(
                    "SAGELINK",
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white),
                  )),
              body: ListView.builder(
                  itemCount: _pageOptions().length,
                  itemBuilder: (BuildContext bc, int index) => ListTile(
                      onTap: () => {_handlePageSelection(index)},
                      title: Text(_pageOptions()[index].tabText),
                      leading: _pageOptions()[index].icon,
                      tileColor: null,
                      selected: _selectedIndex == index,
                      selectedTileColor: Theme.of(bc).colorScheme.secondary,
                      selectedColor: Theme.of(bc).colorScheme.onError,
                      iconColor: Theme.of(bc).colorScheme.onError,
                      textColor: Theme.of(bc).colorScheme.onError))));
    }

    FloatingActionButton? _buildActionButton() {
      return _pageOptions()[_selectedIndex].showFloatingAction
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
          : null;
    }

    return SplitView(
        menu: _buildDrawer(),
        content: PageScaffold(
          title: _pageOptions()[_selectedIndex].title,
          appBarElevation: 0,
          actions: [
            ClickableAvatar(
              avatarText: loggedInUser.getUser().name[0],
              avatarURL: loggedInUser.getUser().accountPictureUrl,
              radius: 20,
              padding: const EdgeInsets.all(10),
              onTap: () => _goToAccount(loggedInUser.getUser().id),
            )
          ],
          body: _pageOptions()[_selectedIndex].body,
          floatingActionButton: _buildActionButton(),
        ));
  }
}
