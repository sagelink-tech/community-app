import 'package:sagelink_communities/ui/views/scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }

  void _onItemTapped(int index, BuildContext context) {
    widget.onSelect(index);
    Navigator.pop(context);
  }

  List<ListTile> _getItems() {
    List<ListTile> items = [];

    widget.tabItems.asMap().forEach((idx, item) {
      items.add(ListTile(
        title: Text(item.tabText),
        leading: item.icon,
        selectedTileColor: Theme.of(context).colorScheme.primary,
        selectedColor: Theme.of(context).colorScheme.onError,
        selected: (widget.selectedIndex == idx),
        onTap: () => {_onItemTapped(idx, context)},
      ));
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return (Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        SizedBox(
            height: 100.0,
            child: DrawerHeader(
              child: Text('SAGELINK',
                  style: Theme.of(context).textTheme.headline6),
            )),
        ..._getItems()
      ]),
    ));
  }
}
