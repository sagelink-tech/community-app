import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/components/stacked_avatars.dart';
import 'package:sagelink_communities/components/universal_image_picker.dart';
import 'package:sagelink_communities/models/cause_model.dart';
import 'package:sagelink_communities/models/logged_in_user.dart';
import 'package:sagelink_communities/providers.dart';
import 'package:sagelink_communities/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/models/brand_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/views/brands/brand_overview.dart';

String getBrandQuery = """
query Brands(\$where: BrandWhere, \$options: BrandOptions, \$membersFirst: Int, \$employeesFirst: Int) {
  brands(where: \$where, options: \$options) {
    id
    name
    description
    website
    mainColor
    logoUrl
    backgroundImageUrl
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
    causes {
      title
      id
    }
  }
}
""";

class AdminBrandHomepage extends ConsumerStatefulWidget {
  const AdminBrandHomepage({Key? key}) : super(key: key);

  static const routeName = '/brands';

  @override
  _AdminBrandHomepageState createState() => _AdminBrandHomepageState();
}

class _AdminBrandHomepageState extends ConsumerState<AdminBrandHomepage>
    with SingleTickerProviderStateMixin {
  BrandModel _brand = BrandModel();
  late final LoggedInUser loggedInUser = ref.watch(loggedInUserProvider);
  bool showingPreview = false;
  Size previewSize = const Size(390, 844); // default to iPhone 13

  // Editing data
  Image? newBannerImage;
  Image? logoImage;
  String description = "";
  List<String> causes = [];
  //List<BrandLink> links = [];

  late final UniversalImagePicker _bannerPicker = UniversalImagePicker(context,
      maxImages: 1, onSelected: _updateBannerImage);
  late final UniversalImagePicker _logoPicker =
      UniversalImagePicker(context, maxImages: 1);

  void _updateBannerImage() {
    if (_bannerPicker.images.isNotEmpty) {
      setState(() {
        newBannerImage =
            Image.file(_bannerPicker.images.first, fit: BoxFit.fitWidth);
      });
    } else {
      setState(() {
        newBannerImage = null;
      });
    }
  }

  void togglePreview() {
    setState(() {
      showingPreview = !showingPreview;
    });
  }

  // Preview Build Functions
  _buildHeader(BuildContext context) {
    return Column(children: [
      InkWell(
          onTap: () => _bannerPicker.openImagePicker(),
          child: SizedBox(
              height: 200.0,
              width: double.infinity,
              child: newBannerImage ?? _brand.bannerImage())),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(children: [
            Text(_brand.name, style: Theme.of(context).textTheme.headline3),
            StackedAvatars(
              [..._brand.employees, ..._brand.members],
              showOverflow: (_brand.totalCommunityCount > 3),
            ),
            const Text("VIP Community"),
          ])),
    ]);
  }

  _buildBody(BuildContext context) {
    return BrandOverview(
      _brand,
      shrinkWrap: true,
      primary: false,
    );
  }

  _buildPreview() {
    return Container(
        clipBehavior: Clip.antiAlias,
        width: previewSize.width,
        height: previewSize.height,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(40)),
            border: Border.all(color: Colors.black)),
        child: ListView(
            shrinkWrap: true,
            primary: false,
            children: [_buildHeader(context), _buildBody(context)]));
  }

  _buildMainPage() {
    return ListView(
        shrinkWrap: true,
        primary: false,
        children: [_buildHeader(context), _buildBody(context)]);
  }

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getBrandQuery),
          variables: {
            "where": {"id": loggedInUser.adminBrandId},
            "options": {"limit": 1},
            "membersFirst": 5,
            "employeesFirst": 5,
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isNotLoading &&
              result.hasException == false &&
              result.data != null) {
            _brand = BrandModel.fromJson(result.data!['brands'][0]);
          }
          return (result.hasException
              ? Center(child: Text(result.exception.toString()))
              : result.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: togglePreview,
                              child: const Text("Preview")),
                        ],
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              primary: true,
                              child: showingPreview
                                  ? _buildPreview()
                                  : _buildMainPage()))
                    ]));
        });
  }
}
