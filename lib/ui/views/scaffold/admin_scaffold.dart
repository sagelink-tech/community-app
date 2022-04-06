import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/empty_result.dart';
import 'package:sagelink_communities/ui/components/page_scaffold.dart';
import 'package:sagelink_communities/ui/components/split_view.dart';
import 'package:sagelink_communities/ui/theme.dart';
import 'package:sagelink_communities/ui/views/admin_pages/brand_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/conversations_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/go_to_admin_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/home_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/members_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/perks_page.dart';
import 'package:sagelink_communities/ui/views/admin_pages/team_page.dart';
import 'package:sagelink_communities/ui/views/brands/brand_home_page.dart';
import 'package:sagelink_communities/ui/views/messages/rooms_page.dart';
import 'package:sagelink_communities/ui/views/messages/users_page.dart';
import 'package:sagelink_communities/ui/views/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/views/perks/new_perk_view.dart';
import 'package:sagelink_communities/ui/views/perks/perk_view.dart';
import 'package:sagelink_communities/ui/views/posts/new_post_view.dart';
import 'package:sagelink_communities/ui/views/posts/post_view.dart';
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

  void createMessageAction(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const UsersPage()));
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
        const Icon(Icons.chat_bubble_outline),
        const AdminConversationsPage(),
        onAction: createPostAction,
      ),
      TabItem("Messages", "Messages", const Icon(Icons.mail_outline),
          const RoomsPage(),
          onAction: createMessageAction, showFloatingAction: true),
      TabItem("Shop", "Shop", const Icon(Icons.shopping_cart_outlined),
          const AdminPerksPage(),
          onAction: createPerkAction),
      TabItem("Team", "Team", const Icon(Icons.groups_outlined),
          const AdminTeamPage(),
          showFloatingAction: false),
      TabItem("Brand", "Brand", const Icon(Icons.casino_outlined),
          const AdminBrandHomepage(),
          showFloatingAction: false),
      TabItem("", "Main", const Icon(Icons.transit_enterexit_outlined),
          const GoToAdminPage(),
          showFloatingAction: false),
      TabItem("", loggedInUser.getUser().name, const Icon(Icons.person_outline),
          const SettingsPage(),
          showFloatingAction: false,
          leading: ClickableAvatar(
            avatarText: loggedInUser.getUser().initials,
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
          color: SLColorFields().darkBackground,
          width: 250,
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: false,
                  bottom: PreferredSize(
                      child: Container(
                        color: SLColorFields().darkDivider,
                        height: 0.5,
                      ),
                      preferredSize: const Size.fromHeight(0.5)),
                  title: Text(
                    "SAGELINK",
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white),
                  )),
              body: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                        height: 0,
                        color: SLColorFields().darkDivider,
                      ),
                  itemCount: _pageOptions().length,
                  itemBuilder: (BuildContext bc, int index) => ListTile(
                      onTap: () => {_handlePageSelection(index)},
                      title: Text(_pageOptions()[index].tabText),
                      leading: _pageOptions()[index].leading ??
                          _pageOptions()[index].icon,
                      tileColor: null,
                      selected: _selectedIndex == index,
                      selectedTileColor: const Color(0x33FFFFFF),
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
          body: Center(
              child: Container(
            color: Theme.of(context).backgroundColor,
            //constraints: const BoxConstraints(maxWidth: 1000, minWidth: 200),
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: _pageOptions()[_selectedIndex].body,
          )),
          floatingActionButton: _buildActionButton(),
        ));
  }
}
