import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/components/error_view.dart';
import 'package:sagelink_communities/components/list_spacer.dart';
import 'package:sagelink_communities/components/loading.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getUserQuery = """
query Users(\$where: UserWhere) {
  users(where: \$where) {
    id
    username
    email
    name
  }
}
""";

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  static const routeName = '/users';

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage>
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

  Future<UserModel?> _getUser(GraphQLClient client) async {
    client.resetStore();
    Map<String, dynamic> variables = {
      "where": {"id": widget.userId},
      "options": {"limit": 1}
    };

    QueryResult result = await client.query(QueryOptions(
        document: gql(getUserQuery),
        variables: variables,
        fetchPolicy: FetchPolicy.noCache));
    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      return UserModel.fromJson(result.data?['users'][0]);
    }
    return null;
  }

  _buildHeader(BuildContext context, bool boxIsScrolled) {
    return <Widget>[
      SliverList(
        delegate: SliverChildListDelegate([
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(children: [
                Column(children: [
                  ClickableAvatar(
                      avatarText: _user.name[0],
                      avatarURL: _user.accountPictureUrl,
                      radius: 40)
                ]),
                const ListSpacer(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_user.username,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.start),
                  Text(_user.name,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.start),
                ]),
              ])),
        ]),
      ),
      SliverAppBar(
          toolbarHeight: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 1,
          snap: false,
          floating: false,
          pinned: true,
          bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.onBackground,
              controller: _tabController,
              tabs: const [
                Tab(text: "Overview"),
                Tab(text: "Brands"),
                Tab(text: "Activity")
              ])),
    ];
  }

  _buildBody(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: _isCollapsed ? 45 : 0),
        child: TabBarView(
          controller: _tabController,
          children: const [
            Text("overview goes here"),
            Text("brands go here"),
            Text("activity goes here"),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = ref.watch(loggedInUserProvider);

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return FutureBuilder(
          future: _getUser(client),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _user = snapshot.data;
            } else if (snapshot.hasError) {
              //TO DO: DEBUG THIS ERROR
              print("RANDOM ERROR...");
              print(snapshot.error);
            }
            return Scaffold(
                appBar: AppBar(
                    title: null,
                    actions: loggedInUser.getUser().id == _user.id
                        ? [
                            IconButton(
                              onPressed: _toggleEditing,
                              icon: Icon(_isEditing ? Icons.done : Icons.edit),
                            )
                          ]
                        : null,
                    backgroundColor: Theme.of(context).backgroundColor,
                    elevation: 0),
                body: (snapshot.hasData
                    ? NestedScrollView(
                        floatHeaderSlivers: false,
                        controller: _scrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) =>
                            _buildHeader(context, innerBoxIsScrolled),
                        body: _buildBody(context))
                    : snapshot.hasError
                        ? const ErrorView()
                        : const Loading()));
          });
    });
  }
}
