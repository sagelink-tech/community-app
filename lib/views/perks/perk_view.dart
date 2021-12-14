import 'package:community_app/components/clickable_avatar.dart';
import 'package:community_app/components/list_spacer.dart';
import 'package:community_app/components/nested_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:community_app/models/perk_model.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getPerkQuery = """
query Posts(\$where: PostWhere, \$options: CommentOptions) {
  posts(where: \$where) {
    id
    title
    body
    createdAt
    createdBy {
      id
      name
      username
    }
    commentsAggregate {
      count
    }
    comments(options: \$options) {
      id
      body
      createdAt
      createdBy {
        id
        name
        username
      }
    }
  }
}
""";

var perkJson = {
  "id": "123",
  "title": "Test Perk",
  "description":
      "This is a test perk for us to see what the visual aesthetic of the consumer application actually looks like. This is going to be a bit longer than necessary just so we can start testing around and whatever. Who knows what I'm actually going to end up writing - probably just some nonsense if I'm being honest. Ok I'm done. This is a test perk for us to see what the visual aesthetic of the consumer application actually looks like. This is going to be a bit longer than necessary just so we can start testing around and whatever. Who knows what I'm actually going to end up writing - probably just some nonsense if I'm being honest. Ok I'm done.",
  "productId": "123",
  "productName": "Test Product",
  "price": 35.0,
  "imageUrls": <String>[
    "https://cdn.shopify.com/s/files/1/1009/9408/products/greentruck-front_1200x.jpg?v=1603296118"
  ],
  "currency": Currencies.usd,
  "type": PerkType.productDrop,
  "startDate": DateTime(2022, 1, 1, 0, 0, 0).toString(),
  "endDate": DateTime(2022, 1, 2, 0, 0, 0).toString(),
  "commentsAggregate": {"count": 0},
  "inBrandCommunity": BrandModel().toJson(),
  "createdBy": UserModel().toJson(),
};

class PerkView extends StatefulWidget {
  const PerkView({Key? key, required this.perkId}) : super(key: key);
  final String perkId;

  static const routeName = '/perks';

  @override
  _PerkViewState createState() => _PerkViewState();
}

class _PerkViewState extends State<PerkView> {
  PerkModel _perk = PerkModel();

  _buildBody(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_perk.typeToString(),
                  style: Theme.of(context).textTheme.subtitle2),
              const SizedBox(height: 5),
              Text(_perk.title, style: Theme.of(context).textTheme.headline3),
              Text("VIP " + _perk.brand.name + " Members Only",
                  style: Theme.of(context).textTheme.bodyText1),
              const SizedBox(height: 5),
              NestedTabBar(const [
                'Description',
                'Details',
                'Conversations'
              ], [
                Text(_perk.description),
                const Text('details go here'),
                const Text('conversations go here')
              ]),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.secondary,
                          onPrimary: Theme.of(context).colorScheme.onError),
                      onPressed: () => {},
                      child: const Text("Redeem")))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getPerkQuery),
          variables: {
            "where": {"id": widget.perkId},
            "options": {"limit": 1},
            "postsOptions": {
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
            //_perk = PerkModel.fromJson(result.data?['perks'][0]);
            _perk = PerkModel.fromJson(perkJson);
          }

          return Scaffold(
              appBar: AppBar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 0),
              body: (result.hasException
                  ? Text(result.exception.toString())
                  : result.isLoading
                      ? const CircularProgressIndicator()
                      : ListView(shrinkWrap: true, children: [
                          SizedBox(
                              height: 192.0,
                              width: double.infinity,
                              child: Image.network(
                                  _perk.imageUrls.isEmpty
                                      ? "http://contrapoderweb.com/wp-content/uploads/2014/10/default-img-400x240.gif"
                                      : _perk.imageUrls[0],
                                  fit: BoxFit.cover)),
                          const SizedBox(height: 5),
                          _buildBody(context)
                        ])));
        });
  }
}
