import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/components/clickable_avatar.dart';
import 'package:sagelink_communities/components/list_spacer.dart';
import 'package:sagelink_communities/components/stacked_avatars.dart';
import 'package:sagelink_communities/components/universal_image_picker.dart';
import 'package:sagelink_communities/models/logged_in_user.dart';
import 'package:sagelink_communities/providers.dart';
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

String updateBrandMutation = """
mutation Mutation(\$where: BrandWhere, \$update: BrandUpdateInput) {
  updateBrands(where: \$where, update: \$update) {
    brands {
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
  bool isSaving = false;

  // Editing data
  Image? newBannerImage;
  Image? newLogoImage;
  String description = "";
  List<String> causes = [];
  //List<BrandLink> links = [];

  // Image Pickers
  late final UniversalImagePicker _bannerPicker = UniversalImagePicker(context,
      maxImages: 1, onSelected: _updateBannerImage);
  late final UniversalImagePicker _logoPicker =
      UniversalImagePicker(context, maxImages: 1, onSelected: _updateLogoImage);

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

  void _updateLogoImage() {
    if (_logoPicker.images.isNotEmpty) {
      setState(() {
        newLogoImage =
            Image.file(_logoPicker.images.first, fit: BoxFit.fitWidth);
      });
    } else {
      setState(() {
        newLogoImage = null;
      });
    }
  }

  // Saving changes
  bool canSave() {
    return !isSaving && (newBannerImage != null || newLogoImage != null);
  }

  Future<bool> _saveChanges(BuildContext context, GraphQLClient client) async {
    setState(() {
      isSaving = true;
    });
    var updateData = {};

    if (newLogoImage != null) {
      // upload logo image
      var logoResult = await _logoPicker.uploadImages("brands/${_brand.id}/",
          imageKeyPrefix: "logo", context: context, client: client);
      if (logoResult.isEmpty || !logoResult[0].success) {
        setState(() {
          isSaving = false;
        });
        return false;
      } else {
        updateData["logoUrl"] = logoResult[0].location;
      }
    }
    if (newBannerImage != null) {
      // upload banner image
      var bannerResult = await _bannerPicker.uploadImages(
          "brands/${_brand.id}/",
          imageKeyPrefix: "banner",
          context: context,
          client: client);
      if (bannerResult.isEmpty || !bannerResult[0].success) {
        setState(() {
          isSaving = false;
        });
        return false;
      } else {
        updateData["backgroundImageUrl"] = bannerResult[0].location;
      }
    }
    print(updateData);
    if (updateData.isEmpty) {
      return false;
    }

    MutationOptions options =
        MutationOptions(document: gql(updateBrandMutation), variables: {
      "where": {"id": _brand.id},
      "update": updateData
    });

    QueryResult result = await client.mutate(options);
    print(result);

    setState(() {
      isSaving = false;
    });
    return !result.hasException &&
        result.data!['updateBrands']['brands'][0]['id'] == _brand.id;
  }

  Widget _buildSaveButton(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return ElevatedButton(
          onPressed: canSave() ? () => {_saveChanges(context, client)} : null,
          child: const Text("Save"));
    });
  }

  // Preview State
  void togglePreview() {
    setState(() {
      showingPreview = !showingPreview;
    });
  }

  // Preview Build
  _buildPreview() {
    var header = Column(children: [
      InkWell(
          onTap: () => _bannerPicker.openImagePicker(),
          child: SizedBox(
              height: 200.0,
              width: double.infinity,
              child: newBannerImage ?? _brand.bannerImage())),
      InkWell(
          onTap: () => _logoPicker.openImagePicker(),
          child: ClickableAvatar(
            avatarText: _brand.name[0],
            avatarImage: newLogoImage ?? _brand.logoImage(),
            radius: 40,
          )),
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

    var body = BrandOverview(
      _brand,
      shrinkWrap: true,
      primary: false,
    );

    return Container(
        clipBehavior: Clip.antiAlias,
        width: previewSize.width,
        height: previewSize.height,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(40)),
            border: Border.all(color: Colors.black)),
        child: ListView(
            shrinkWrap: true, primary: false, children: [header, body]));
  }

  // Main Page build
  _buildMainPage() {
    var bgSelection = DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [5],
        color: Theme.of(context).primaryColor,
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: SizedBox(
                height: 200.0,
                width: previewSize.width,
                child: InkWell(
                    onTap: () => _bannerPicker.openImagePicker(),
                    child: newBannerImage ?? _brand.bannerImage()))));

    var logoSelection = DottedBorder(
        borderType: BorderType.Circle,
        radius: const Radius.circular(10),
        dashPattern: const [5],
        color: Theme.of(context).primaryColor,
        child: Container(
            alignment: Alignment.center,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
            ),
            child: ClickableAvatar(
                onTap: _logoPicker.openImagePicker,
                avatarText: _brand.name[0],
                avatarImage: newLogoImage ?? _brand.logoImage(),
                radius: 40)));

    return ListView(shrinkWrap: true, primary: false, children: [
      Text("Banner Image", style: Theme.of(context).textTheme.headline4),
      bgSelection,
      const ListSpacer(),
      Text("Logo Image", style: Theme.of(context).textTheme.headline4),
      logoSelection
    ]);
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
              : result.isLoading || isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildSaveButton(context),
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
