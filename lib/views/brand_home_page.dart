import 'package:flutter/material.dart';
import 'package:community_app/commands/get_brand_command.dart';
import 'package:community_app/models/brand_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
  void initState() {
    super.initState();
  }

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
                        : Text(_brand.description))),
          );
        });
  }
}
