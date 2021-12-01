import 'package:community_app/models/logged_in_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_app/providers.dart';

class HomeNavTabMenu extends ConsumerStatefulWidget {
  const HomeNavTabMenu({Key? key, required this.onSelect}) : super(key: key);

  final void Function(int index) onSelect;

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

  @override
  Widget build(BuildContext context) {
    final loggedInUser = ref.watch(loggedInUserProvider);

    return (BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined), label: 'Perks'),
        BottomNavigationBarItem(
            icon: Icon(Icons.casino_outlined), label: 'Brands'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: "Settings")
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    ));
  }
}
