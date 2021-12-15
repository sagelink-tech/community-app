import 'package:flutter/material.dart';

class NestedTabBar extends StatefulWidget {
  final List<String> labels;
  final List<Widget> tabBodies;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  const NestedTabBar(this.labels, this.tabBodies,
      {this.crossAxisAlignment = CrossAxisAlignment.start,
      this.mainAxisAlignment = MainAxisAlignment.start,
      Key? key})
      : super(key: key);

  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  late TabController _nestedTabController;

  @override
  void initState() {
    super.initState();
    _nestedTabController =
        TabController(length: widget.labels.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  _buildLabels() {
    return widget.labels.map((e) => Tab(text: e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: <Widget>[
        TabBar(
          controller: _nestedTabController,
          labelColor: Theme.of(context).colorScheme.onBackground,
          isScrollable: true,
          tabs: _buildLabels(),
        ),
        SizedBox(
          height: 0.35 * MediaQuery.of(context).size.height,
          child: TabBarView(
              controller: _nestedTabController, children: widget.tabBodies),
        )
      ],
    );
  }
}
