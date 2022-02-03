import 'package:sagelink_communities/ui/components/empty_result.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/image_carousel.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/comments/comment_list.dart';
import 'package:sagelink_communities/ui/views/comments/new_comment.dart';

String getPerkQuery = """
query GetPerksQuery(\$options: PerkOptions, \$where: PerkWhere, \$commentOptions: CommentOptions) {
  perks(options: \$options, where: \$where) {
    id
    title
    description
    details
    imageUrls
    productName
    productId
    price
    createdAt
    startDate
    endDate
    type
    createdBy {
      id
      name
      accountPictureUrl
    }
    commentsAggregate {
      count
    }
    inBrandCommunity {
      id
      name
      mainColor
    }
    comments(options: \$commentOptions) {
      id
      body
      createdAt
      createdBy {
        id
        name
        accountPictureUrl
      }
      repliesAggregate {
        count
      }
    }
  }
}
""";

class PerkView extends StatefulWidget {
  const PerkView({Key? key, required this.perkId}) : super(key: key);
  final String perkId;

  static const routeName = '/perks';

  @override
  _PerkViewState createState() => _PerkViewState();
}

class _PerkViewState extends State<PerkView>
    with SingleTickerProviderStateMixin {
  PerkModel _perk = PerkModel();
  bool showingThread = false;
  String? _threadId;
  bool _isCollapsed = false;
  final double _headerSize = 200.0;
  int _currentIndex = 0;

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

  _tabListener() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(_scrollListener);
    _tabController.addListener(_tabListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCommentThread(String commentId) {
    setState(() {
      showingThread = true;
      _threadId = commentId;
    });
  }

  void completeReplyOnThread(String commentId) {
    setState(() {
      showingThread = false;
      _threadId = null;
    });
  }

  _buildHeader(BuildContext context, bool boxIsScrolled) {
    return <Widget>[
      SliverList(
        delegate: SliverChildListDelegate([
          EmbeddedImageCarousel(_perk.imageUrls, height: 192.0),
          const SizedBox(height: 5),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Text(_perk.typeToString(),
                    style: Theme.of(context).textTheme.subtitle2),
                const SizedBox(height: 5),
                Text(_perk.title, style: Theme.of(context).textTheme.headline3),
                Text("VIP " + _perk.brand.name + " Members Only",
                    style: Theme.of(context).textTheme.bodyText1),
              ])),
        ]),
      ),
      SliverAppBar(
          toolbarHeight: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 1,
          floating: false,
          pinned: true,
          bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.onBackground,
              controller: _tabController,
              tabs: const [
                Tab(text: "Description"),
                Tab(text: "Details"),
                Tab(text: "Conversation")
              ])),
    ];
  }

  _buildBody(BuildContext context, VoidCallback? refetch) {
    return Container(
        padding:
            EdgeInsets.only(left: 24, right: 24, top: _isCollapsed ? 45 : 0),
        child: TabBarView(
          controller: _tabController,
          children: [
            Text(_perk.description, style: Theme.of(context).textTheme.caption),
            Text(_perk.details, style: Theme.of(context).textTheme.caption),
            _perk.comments.isNotEmpty
                ? CommentListView(
                    _perk.comments,
                    brandId: _perk.brand.id,
                    onAddReply: (commentId) => {
                      completeReplyOnThread(commentId),
                      if (refetch != null) refetch()
                    },
                    onShowThread: _showCommentThread,
                    onCloseThread: () => {
                      setState(() {
                        showingThread = false;
                      }),
                      if (refetch != null) refetch()
                    },
                  )
                : const EmptyResult(text: "No conversation started yet!")
          ],
        ));
  }

  Widget _buildButtons(BuildContext context, VoidCallback? refetch) {
    if (_currentIndex == 2) {
      return Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: NewComment(
            parentId: showingThread ? _threadId! : _perk.id,
            onCompleted: () => refetch != null ? refetch() : null,
            isOnPerk: true,
            isReply: showingThread,
          ));
    } else {
      return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                  onPrimary: Theme.of(context).colorScheme.onError),
              onPressed: () => {},
              child: const Text("Redeem")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getPerkQuery),
          variables: {
            "where": {"id": widget.perkId},
            "options": {"limit": 1},
            "commentOptions": {
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
            _perk = PerkModel.fromJson(result.data?['perks'][0]);
          }

          return Scaffold(
              appBar: AppBar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 0),
              body: (result.hasException
                  ? const ErrorView()
                  : result.isLoading
                      ? const Loading()
                      : Stack(alignment: Alignment.bottomCenter, children: [
                          NestedScrollView(
                              floatHeaderSlivers: false,
                              controller: _scrollController,
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) =>
                                      _buildHeader(context, innerBoxIsScrolled),
                              body: _buildBody(context, refetch)),
                          _buildButtons(context, refetch)
                        ])));
        });
  }
}
