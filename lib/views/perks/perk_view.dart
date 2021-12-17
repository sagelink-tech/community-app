import 'package:community_app/components/image_carousel.dart';
import 'package:flutter/material.dart';
import 'package:community_app/models/perk_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getPerkQuery = """
query GetPerksQuery(\$options: PerkOptions, \$where: PerkWhere) {
  perks(options: \$options, where: \$where) {
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
    createdBy {
      id
      name
      username
    }
    commentsAggregate {
      count
    }
    inBrandCommunity {
      id
      name
      mainColor
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
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                Tab(text: "Conversations")
              ])),
    ];
  }

  _buildBody(BuildContext context) {
    return Container(
        padding:
            EdgeInsets.only(left: 24, right: 24, top: _isCollapsed ? 45 : 0),
        child: TabBarView(
          controller: _tabController,
          children: [
            Text(_perk.description, style: Theme.of(context).textTheme.caption),
            const Text('details go here'),
            const Text('conversations go here')
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getPerkQuery),
          variables: {
            "where": {"id": widget.perkId},
            "options": {"limit": 1},
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
                  ? Text(result.exception.toString())
                  : result.isLoading
                      ? const CircularProgressIndicator()
                      : Stack(alignment: Alignment.bottomCenter, children: [
                          NestedScrollView(
                              floatHeaderSlivers: false,
                              controller: _scrollController,
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) =>
                                      _buildHeader(context, innerBoxIsScrolled),
                              body: _buildBody(context)),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      onPrimary: Theme.of(context)
                                          .colorScheme
                                          .onError),
                                  onPressed: () => {},
                                  child: const Text("Redeem")))
                        ])));
        });
  }
}
