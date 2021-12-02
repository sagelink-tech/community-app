import 'package:community_app/models/logged_in_user.dart';
import 'package:community_app/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_app/providers.dart';

class HomeNavTabMenu extends ConsumerStatefulWidget {
  const HomeNavTabMenu(
      {Key? key, required this.onSelect, required this.tabItems})
      : super(key: key);

  final void Function(int index) onSelect;
  final List<TabItem> tabItems;

  @override
  _HomeNavTabMenuState createState() => _HomeNavTabMenuState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _HomeNavTabMenuState extends ConsumerState<HomeNavTabMenu> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final loggedInUser = ref.read(loggedInUserProvider);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onSelect(index);
  }

  List<BottomNavigationBarItem> _getItems() {
    List<BottomNavigationBarItem> items = [];
    for (var item in widget.tabItems) {
      items.add(BottomNavigationBarItem(icon: item.icon, label: item.tabText));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = ref.watch(loggedInUserProvider);

    return (BottomNavigationBar(
      items: _getItems(),
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Theme.of(context).colorScheme.onSecondary,
      onTap: _onItemTapped,
    ));
  }
}
