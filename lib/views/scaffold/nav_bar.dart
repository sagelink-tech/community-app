import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_app/providers.dart';
import 'package:community_app/views/account_page.dart';

class HomeNavDrawerMenu extends ConsumerStatefulWidget {
  const HomeNavDrawerMenu(
      {Key? key, required this.onSelect, required this.selectedIndex})
      : super(key: key);

  final void Function(int index) onSelect;
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
        ListTile(
          title: const Text('Home'),
          leading: const Icon(Icons.home_outlined),
          selectedTileColor: Colors.grey,
          selectedColor: Colors.black,
          selected: (widget.selectedIndex == 0),
          onTap: () => {_onItemTapped(0, context)},
        ),
        ListTile(
          title: const Text('Perks'),
          leading: const Icon(Icons.shopping_cart_outlined),
          selectedTileColor: Colors.grey,
          selectedColor: Colors.black,
          selected: (widget.selectedIndex == 1),
          onTap: () => {_onItemTapped(1, context)},
        ),
        ListTile(
          title: const Text('Brands'),
          leading: const Icon(Icons.casino_outlined),
          selectedTileColor: Colors.grey,
          selectedColor: Colors.black,
          selected: (widget.selectedIndex == 2),
          onTap: () => {_onItemTapped(2, context)},
        ),
        ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings_outlined),
          selectedTileColor: Colors.grey,
          selectedColor: Colors.black,
          selected: (widget.selectedIndex == 3),
          onTap: () => {_onItemTapped(3, context)},
        ),
        ListTile(
          title: const Text('Logout'),
          onTap: () => {ref.read(loggedInUserProvider.notifier).logout()},
        )
      ]),
    ));
  }
}
