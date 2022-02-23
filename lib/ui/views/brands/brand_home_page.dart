import 'package:sagelink_communities/ui/components/stacked_avatars.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/data/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/brands/brand_overview.dart';
import 'package:sagelink_communities/ui/views/perks/perk_list.dart';
import 'package:sagelink_communities/ui/views/posts/new_post_view.dart';
import 'package:sagelink_communities/ui/views/posts/post_list.dart';
import 'package:sagelink_communities/ui/views/users/user_list.dart';

String getBrandQuery = """
query Brands(\$where: BrandWhere, \$options: BrandOptions, \$postsOptions: PostOptions, \$perksOptions: PerkOptions, \$membersFirst: Int, \$employeesFirst: Int) {
  brands(where: \$where, options: \$options) {
    id
    name
    description
    website
    mainColor
    logoUrl
    backgroundImageUrl
    posts(options: \$postsOptions) {
      commentsAggregate {
        count
      }
      createdBy {
        id
        name
        accountPictureUrl
        queryUserHasBlocked
      }
      title
      body
      isFlaggedByUser
      id
      linkUrl
      images
      type
      createdAt
    }
    employeesConnection(first: \$employeesFirst) {
      totalCount
      edges {
        node {
          id
          name
          accountPictureUrl
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
          accountPictureUrl
        }
      }
    }
    perks(options: \$perksOptions) {
      id
      title
      description
      imageUrls
      productName
      productId
      price
      createdAt
      startDate
      endDate
    }
    causes {
      title
      id
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
  List<PerkModel> _perks = [];

  bool _isCollapsed = false;
  final double _headerSize = 200.0;

  late final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.0);
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

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
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
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
                  : CachedNetworkImage(
                      imageUrl: _brand.backgroundImageUrl,
                      placeholderFadeInDuration:
                          const Duration(milliseconds: 10),
                      placeholder: (context, url) =>
                          AssetUtils.wrappedDefaultImage(
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                          ),
                      fit: BoxFit.fitWidth)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [
                Text(_brand.name, style: Theme.of(context).textTheme.headline3),
                InkWell(
                    onTap: () => {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext bc) {
                                return UserListView(
                                    [..._brand.employees, ..._brand.members]);
                              })
                        },
                    child: StackedAvatars(
                      [..._brand.employees, ..._brand.members],
                      showOverflow: (_brand.totalCommunityCount > 3),
                    )),
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
                Tab(text: "Shop"),
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
            PerkListView(_perks, (context, perkId) => {}, showBrand: false),
            BrandOverview(_brand),
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
            "employeesFirst": 5,
            "perksOptions": {
              "limit": 10,
              "sort": [
                {"createdAt": "DESC"}
              ]
            }
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
              if (!post.isFlaggedByUser && !post.creator.queryUserHasBlocked) {
                posts.add(post);
              }
            }
            _posts = posts;
            List<PerkModel> perks = [];
            for (var p in result.data?['brands'][0]['perks']) {
              PerkModel perk = PerkModel.fromJson(p);
              perk.brand = _brand;
              perks.add(perk);
            }
            _perks = perks;
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
