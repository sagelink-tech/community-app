import 'package:flutter/material.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:community_app/views/posts/new_post_view.dart';

String getBrandQuery = """
query Brands(\$where: BrandWhere) {
  brands(where: \$where) {
    id
    name
    description
    mainColor
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

class _BrandHomepageState extends State<BrandHomepage> {
  BrandModel _brand = BrandModel();

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getBrandQuery),
          variables: {
            "where": {"id": widget.brandId},
            "options": {"limit": 1}
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            _brand = BrandModel.fromJson(result.data?['brands'][0]);
          }
          return Scaffold(
              appBar: AppBar(
                title: result.isLoading || result.hasException
                    ? const Text('')
                    : Text(_brand.name),
                backgroundColor: _brand.mainColor,
              ),
              body: Center(
                child: (result.hasException
                    ? Text(result.exception.toString())
                    : result.isLoading
                        ? const CircularProgressIndicator()
                        : ListView(children: [
                            Text(_brand.description),
                            buildNewPostButton()
                          ])),
              ));
        });
  }

  Widget buildNewPostButton() => TextButton(
      child: const Text("New Post"),
      onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewPostPage(brandId: widget.brandId)))
          });
}
