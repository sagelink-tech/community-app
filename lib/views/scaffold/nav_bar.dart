import 'package:community_app/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_app/providers.dart';
import 'package:community_app/views/account_page.dart';

class HomeNavDrawerMenu extends ConsumerStatefulWidget {
  const HomeNavDrawerMenu(
      {Key? key,
      required this.onSelect,
      required this.tabItems,
      required this.selectedIndex})
      : super(key: key);

  final void Function(int index) onSelect;
  final List<TabItem> tabItems;
  final int selectedIndex;

  @override
  _HomeNavDrawerMenuState createState() => _HomeNavDrawerMenuState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _HomeNavDrawerMenuState extends ConsumerState<HomeNavDrawerMenu> {
  @override
  void initState() {
    super.initState();
    final loggedInUser = ref.read(loggedInUserProvider);
  }

  void _onItemTapped(int index, BuildContext context) {
    widget.onSelect(index);
    Navigator.pop(context);
  }

  void _goToAccount(BuildContext context, String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  List<ListTile> _getItems() {
    List<ListTile> items = [];

    widget.tabItems.asMap().forEach((idx, item) {
      items.add(ListTile(
        title: Text(item.title),
        leading: item.icon,
        selectedTileColor: Colors.grey,
        selectedColor: Colors.black,
        selected: (widget.selectedIndex == idx),
        onTap: () => {_onItemTapped(idx, context)},
      ));
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = ref.watch(loggedInUserProvider);
    return (Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        UserAccountsDrawerHeader(
          accountName: const Text("Test"),
          accountEmail: const Text("test@test.com"),
          decoration: const BoxDecoration(color: Colors.blueGrey),
          onDetailsPressed: () {
            Navigator.pop(context);
            _goToAccount(context, loggedInUser.userId);
          },
        ),
        ..._getItems()
      ]),
    ));
  }
}
