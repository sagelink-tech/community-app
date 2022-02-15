import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  UserModel _user = UserModel();

  bool _isEditing = false;

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  bool _isCollapsed = false;
  final double _headerSize = 50.0;

  late ScrollController _scrollController;
  late TabController _tabController;

  _scrollListener() {
    if (_scrollController.offset >= _headerSize) {
      setState(() {
        _isCollapsed = true;
      });
    } else {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  _buildBody(BuildContext context, AuthState auth) {
    return TabBarView(
      controller: _tabController,
      children: [
        ListView(
          children: [
            SwitchListTile(
                title: const Text("New perks"),
                value: false,
                onChanged: (value) => {}),
            SwitchListTile(
                title: const Text("Mentions"),
                value: false,
                onChanged: (value) => {}),
            SwitchListTile(
                title: const Text("Replies to authored posts"),
                value: false,
                onChanged: (value) => {}),
            SwitchListTile(
                title: const Text("New posts"),
                value: false,
                onChanged: (value) => {}),
          ],
        ),
        const Text("data sharing goes here"),
        ListView(
          children: [
            const ListTile(title: Text("Privacy Policy")),
            const ListTile(title: Text("Terms and Conditions")),
            ListTile(title: const Text("Logout"), onTap: () => auth.signOut()),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = ref.watch(loggedInUserProvider);
    _user = loggedInUser.getUser();

    final auth = ref.watch(authProvider.notifier);

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 0.0,
            title: null,
            bottom: TabBar(
                labelColor: Theme.of(context).colorScheme.onBackground,
                controller: _tabController,
                tabs: const [
                  Tab(text: "Notifications"),
                  Tab(text: "Data Sharing"),
                  Tab(text: "Other")
                ]),
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0),
        body: _buildBody(context, auth));
  }
}
