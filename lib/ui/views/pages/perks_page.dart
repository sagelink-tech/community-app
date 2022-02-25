import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/brand_chip.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:sagelink_communities/ui/views/perks/perk_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getPerksQuery = '''
query GetPerksQuery(\$options: PerkOptions, \$where: PerkWhere) {
  perks(options: \$options, where: \$where) {
    id
    title
    type
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
      accountPictureUrl
    }
    commentsAggregate {
      count
    }
    inBrandCommunity {
      id
      name
      mainColor
      logoUrl
    }
  }
}
''';

class PerksPage extends ConsumerStatefulWidget {
  const PerksPage({Key? key}) : super(key: key);

  static const routeName = '/perks';

  @override
  _PerksPageState createState() => _PerksPageState();
}

class _PerksPageState extends ConsumerState<PerksPage> {
  late final userBrands = ref.watch(brandsProvider);
  late final client = ref.watch(gqlClientProvider).value;

  late List<String> selectedBrandIds =
      brands.where((e) => e != null).map((e) => e!.id).toList();
  late List<BrandModel?> brands =
      userBrands.length > 1 ? [null, ...userBrands] : userBrands;
  List<PerkModel> perks = [];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      _getPerks();
    });
  }

  void _handleBrandFilter(BrandModel? brand, bool selected) {
    List<String> updatedIds = selectedBrandIds;

    // if selecting "My Brands", default to []
    if (brand == null) {
      updatedIds = [];
    } else {
      // if selecting a different brand, add to list
      if (selected && !selectedBrandIds.contains(brand.id)) {
        updatedIds.add(brand.id);
      }
      // if deselecting a brand, remove from list
      else if (!selected && selectedBrandIds.contains(brand.id)) {
        updatedIds.remove(brand.id);
      }
    }

    setState(() {
      selectedBrandIds = updatedIds;
    });
  }

  QueryOptions qOptions() {
    Map<String, dynamic> variables = {
      "options": {
        "sort": [
          {"createdAt": "DESC"}
        ],
      },
      "where": {}
    };
    if (selectedBrandIds.isNotEmpty) {
      variables['where']['inBrandCommunity'] = {"id_IN": selectedBrandIds};
    }
    return QueryOptions(
      document: gql(getPerksQuery),
      variables: variables,
    );
  }

  Future<void> _getPerks() async {
    setState(() {
      _isFetching = true;
      perks = [];
    });

    List<PerkModel> _perks = [];

    QueryResult result = await client.query(qOptions());

    if (result.data != null && (result.data!['perks'] as List).isNotEmpty) {
      List perkJsons = result.data!['perks'] as List;
      _perks = perkJsons.map((e) => PerkModel.fromJson(e)).toList();
    }
    setState(() {
      _isFetching = false;
      perks = _perks;
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildBrandChips() {
      return SizedBox(
          height: 50,
          child: ListView.separated(
              padding: const EdgeInsets.all(5),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 5);
              },
              itemCount: brands.length,
              itemBuilder: (context, index) => BrandChip(
                    brand: brands[index],
                    selected: (index > 0
                        ? selectedBrandIds
                            .contains((brands[index] as BrandModel).id)
                        : selectedBrandIds.isEmpty),
                    onSelection: _handleBrandFilter,
                  )));
    }

    _buildPerkCells() {
      return RefreshIndicator(
        child: _isFetching
            ? const Loading()
            : PerkListView(perks, (context, postId) => {}),
        onRefresh: _getPerks,
      );
    }

    return Column(
        children: brands.length > 1
            ? [
                _buildBrandChips(),
                const SizedBox(height: 10),
                Expanded(child: _buildPerkCells())
              ]
            : [Expanded(child: _buildPerkCells())]);
  }
}
