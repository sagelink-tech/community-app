import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/empty_result.dart';
import 'package:sagelink_communities/ui/components/page_scaffold.dart';
import 'package:sagelink_communities/ui/components/split_view.dart';
import 'package:sagelink_communities/ui/views/admin_pages/brand_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/conversations_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/go_to_admin_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/home_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/members_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/perks_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/team_page.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';
import 'package:sagelink_communities/ui/views/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/views/perks/new_perk_view.dart';
import 'package:sagelink_communities/ui/views/posts/new_post_view.dart';
import 'package:sagelink_communities/ui/views/scaffold/main_scaffold.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  const AdminScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<AdminScaffold> {
  int _selectedIndex = 0;
  late List<TabItem> pages;
  late final loggedInUser = ref.watch(loggedInUserProvider);

  void createPostAction(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NewPostPage(
            brandId: loggedInUser.adminBrandId!, onCompleted: () => {})));
  }

  void createPerkAction(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NewPerkPage(
            brandId: loggedInUser.adminBrandId!, onCompleted: () => {})));
  }

  List<TabItem> _pageOptions() {
    var _pages = [
      TabItem(
          "", "Home", const Icon(Icons.home_outlined), const AdminHomePage(),
          onAction: createPostAction),
      TabItem("Members", "Members", const Icon(Icons.people_outline),
          const AdminMembersPage(),
          showFloatingAction: false),
      TabItem(
        "Conversations",
        "Conversations",
        const Icon(Icons.forum_outlined),
        const AdminConversationsPage(),
        onAction: createPostAction,
      ),
      TabItem("Messages", "Messages", const Icon(Icons.chat_bubble_outlined),
          const EmptyResult(text: "Messages"),
          onAction: createPostAction),
      TabItem("Perks", "Perks", const Icon(Icons.shopping_cart_outlined),
          const AdminPerksPage(),
          onAction: createPerkAction),
      TabItem("Team", "Team", const Icon(Icons.groups_outlined),
          const AdminTeamPage(),
          showFloatingAction: false),
      TabItem("Brand", "Brand", const Icon(Icons.casino_outlined),
          const AdminBrandHomepage(),
          showFloatingAction: false),
      TabItem("Settings", "Settings", const Icon(Icons.settings_outlined),
          const SettingsPage(),
          showFloatingAction: false),
      TabItem("", "Main", const Icon(Icons.transit_enterexit_outlined),
          const GoToAdminPage(),
          showFloatingAction: false),
      TabItem("", loggedInUser.getUser().name, const Icon(Icons.person_outline),
          AccountPage(userId: loggedInUser.getUser().id),
          showFloatingAction: false,
          leading: ClickableAvatar(
            avatarText: loggedInUser.getUser().name[0],
            avatarURL: loggedInUser.getUser().accountPictureUrl,
            radius: 15,
            padding: const EdgeInsets.all(0),
          ))
    ];
    return _pages;
  }

  @override
  Widget build(BuildContext context) {
    bool showSmallScreen = MediaQuery.of(context).size.shortestSide <= 550;

    void _handlePageSelection(int index) {
      setState(() {
        _selectedIndex = index;
      });
      if (showSmallScreen) {
        Navigator.pop(context);
      }
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
                      leading: _pageOptions()[index].leading ??
                          _pageOptions()[index].icon,
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
                _pageOptions()[_selectedIndex].onAction?.call(context);
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
          actions: _pageOptions()[_selectedIndex].scaffoldAction != null
              ? [_pageOptions()[_selectedIndex].scaffoldAction!]
              : [],
          body: _pageOptions()[_selectedIndex].body,
          floatingActionButton: _buildActionButton(),
        ));
  }
}
