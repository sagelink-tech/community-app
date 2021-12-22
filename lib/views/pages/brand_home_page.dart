import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/models/brand_model.dart';
import 'package:sagelink_communities/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/views/pages/account_page.dart';
import 'package:sagelink_communities/views/posts/new_post_view.dart';
import 'package:sagelink_communities/views/posts/post_list.dart';

String getBrandQuery = """
query Brands(\$where: BrandWhere, \$options: BrandOptions, \$postsOptions: PostOptions, \$membersFirst: Int, \$employeesFirst: Int) {
  brands(where: \$where, options: \$options) {
    id
    name
    description
    website
    mainColor
    logoUrl
    posts(options: \$postsOptions) {
      commentsAggregate {
        count
      }
      createdBy {
        id
        name
        username
      }
      title
      body
      id
    }
    employeesConnection(first: \$employeesFirst) {
      totalCount
      edges {
        node {
          id
          name
          username
        }
        roles
        founder
        owner
        jobTitle
      }
    }
    membersConnection(first: \$membersFirst) {
      totalCount
      edges {
        node {
          id
          name
          username
        }
      }
    }
  }
}
""";

class BrandHomepage extends StatefulWidget {
  const BrandHomepage({Key? key, required this.brandId}) : super(key: key);
  final String brandId;

  static const routeName = '/brands';

  @override
  _BrandHomepageState createState() => _BrandHomepageState();
}

class _BrandHomepageState extends State<BrandHomepage>
    with SingleTickerProviderStateMixin {
  BrandModel _brand = BrandModel();
  List<PostModel> _posts = [];
  bool _isCollapsed = false;
  final double _headerSize = 200.0;

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

  // Navigation
  _goToAccount(String userId) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  // Build Functions
  _buildHeader(BuildContext context, bool boxIsScrolled) {
    return <Widget>[
      SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
              height: 200.0,
              width: double.infinity,
              child: _brand.backgroundImageUrl.isEmpty
                  ? AssetUtils.defaultImage()
                  : Image.network(_brand.backgroundImageUrl,
                      fit: BoxFit.cover)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [
                Text(_brand.name, style: Theme.of(context).textTheme.headline3),
                Text(_brand.totalCommunityCount.toString() + " members"),
                const Text("VIP Community"),
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
                Tab(text: "Conversations"),
                Tab(text: "My Perks"),
                Tab(text: "Overview")
              ])),
    ];
  }

  _buildBody(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: _isCollapsed ? 45 : 0),
        child: TabBarView(
          controller: _tabController,
          children: [
            PostListView(_posts, (context, postId) => {}, showBrand: false),
            const Text("perks go here"),
            Column(
              children: [
                const Text("People"),
                Expanded(
                    child: ListView(
                        children: _brand.employees
                            .map((e) => ListTile(
                                  leading: ClickableAvatar(
                                      avatarText: e.name[0],
                                      avatarURL: e.accountPictureUrl),
                                  title: Text(e.name),
                                  subtitle: Text(e.jobTitle),
                                  onTap: () => _goToAccount(e.id),
                                ))
                            .toList())),
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getBrandQuery),
          variables: {
            "where": {"id": widget.brandId},
            "options": {"limit": 1},
            "postsOptions": {
              "limit": 10,
              "sort": [
                {"createdAt": "DESC"}
              ]
            },
            "membersFirst": 5,
            "employeesFirst": 5
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isNotLoading &&
              result.hasException == false &&
              result.data != null) {
            _brand = BrandModel.fromJson(result.data?['brands'][0]);
            List<PostModel> posts = [];
            for (var p in result.data?['brands'][0]['posts']) {
              PostModel post = PostModel.fromJson(p);
              post.brand = _brand;
              posts.add(post);
            }
            _posts = posts;
          }
          return Scaffold(
              appBar: AppBar(
                  elevation: 0,
                  actions: [
                    buildNewPostButton(refetch!),
                  ],
                  backgroundColor: Theme.of(context).backgroundColor),
              body: (result.hasException
                  ? Center(child: Text(result.exception.toString()))
                  : result.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : NestedScrollView(
                          floatHeaderSlivers: false,
                          controller: _scrollController,
                          headerSliverBuilder: (context, innerBoxIsScrolled) =>
                              _buildHeader(context, innerBoxIsScrolled),
                          body: _buildBody(context))));
        });
  }

  Widget buildNewPostButton(OnCompletionCallback onCompleted) => IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewPostPage(
                        brandId: widget.brandId, onCompleted: onCompleted)))
          });
}
