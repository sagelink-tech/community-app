import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/ui/components/causes_chips.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/stacked_avatars.dart';
import 'package:sagelink_communities/ui/components/universal_image_picker.dart';
import 'package:sagelink_communities/data/models/cause_model.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/brands/brand_overview.dart';

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
    communityGuidelines
    links {
      id
      title
      url
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
    causes {
      title
      id
    }
  }
}
""";

String updateBrandMutation = """
mutation UpdateBrands(\$where: BrandWhere, \$update: BrandUpdateInput, \$connectOrCreate: BrandConnectOrCreateInput, \$disconnect: BrandDisconnectInput) {
  updateBrands(where: \$where, update: \$update, connectOrCreate: \$connectOrCreate, disconnet: \$disconnect) {
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
  late String newDescription = _brand.description;
  late List<CauseModel> causes = _brand.causes;
  late String newGuidelines = _brand.communityGuidelines;
  late List<BrandLink> links = _brand.links;

  TextEditingController causesTextController = TextEditingController();
  // Text controller functions
  void formatAndEnterCause(String value) {
    List<CauseModel> _newCauses = value.split(',').map((element) {
      element.trim();
      return CauseModel("tmp_" + element, element.toLowerCase().trim());
    }).toList();

    setState(() {
      causes = _newCauses;
    });
    causesTextController.clear();
  }

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
    return !isSaving &&
        (newBannerImage != null ||
            newLogoImage != null ||
            newDescription != _brand.description ||
            !listEquals(causes, _brand.causes));
  }

  Future<bool> _saveChanges(BuildContext context, GraphQLClient client) async {
    // No changes to make
    if (!canSave()) {
      return false;
    }

    // Start saving
    setState(() {
      isSaving = true;
    });

    var updateData = {
      "description": newDescription,
      "communityGuidelines": newGuidelines,
    };

    // parse causes
    var newCausesSet = causes.toSet();
    var oldCausesSet = _brand.causes.toSet();
    var causesToRemove = oldCausesSet.difference(newCausesSet).toList();
    var causesToAdd = newCausesSet.difference(oldCausesSet).toList();

    // initialize mutation variables
    var mutationVariables = {
      "where": {"id": _brand.id},
      "disconnect": {
        "causes": causesToRemove
            .map((e) => {
                  "where": {
                    "node": {"id": e.id}
                  }
                })
            .toList()
      },
      "connectOrCreate": {
        "causes": causesToAdd
            .map((e) => {
                  "where": {
                    "node": {"title": e.title}
                  },
                  "onCreate": {
                    "node": {"title": e.title}
                  }
                })
            .toList()
      }
    };

    if (newLogoImage != null) {
      // upload logo image
      var logoResult = await _logoPicker.uploadImages("brands/${_brand.id}/",
          imageKeyPrefix: "logo", context: context, client: client);

      if (!logoResult.success) {
        setState(() {
          isSaving = false;
        });
        return false;
      } else {
        updateData["logoUrl"] = logoResult.locations[0];
      }
    }
    if (newBannerImage != null) {
      // upload banner image
      var bannerResult = await _bannerPicker.uploadImages(
          "brands/${_brand.id}/",
          imageKeyPrefix: "banner",
          context: context,
          client: client);
      if (!bannerResult.success) {
        setState(() {
          isSaving = false;
        });
        return false;
      } else {
        updateData["backgroundImageUrl"] = bannerResult.locations[0];
      }
    }

    mutationVariables["update"] = updateData;

    // Update
    MutationOptions options = MutationOptions(
        document: gql(updateBrandMutation), variables: mutationVariables);

    QueryResult result = await client.mutate(options);

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
    BrandModel previewBrand = _brand;
    previewBrand.description = newDescription;
    previewBrand.causes = causes;

    var header = Column(children: [
      InkWell(
          onTap: () => _bannerPicker.openImagePicker(),
          child: SizedBox(
              height: 200.0,
              width: double.infinity,
              child: newBannerImage ?? previewBrand.bannerImage())),
      InkWell(
          onTap: () => _logoPicker.openImagePicker(),
          child: ClickableAvatar(
            avatarText: previewBrand.initials,
            avatarImage: newLogoImage ?? previewBrand.logoImage(),
            radius: 40,
          )),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(children: [
            Text(previewBrand.name,
                style: Theme.of(context).textTheme.headline3),
            StackedAvatars(
              [...previewBrand.employees, ...previewBrand.members],
              showOverflow: (previewBrand.totalCommunityCount > 3),
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
            borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                avatarText: _brand.initials,
                avatarImage: newLogoImage ?? _brand.logoImage(),
                radius: 40)));

    var missionTextBox = TextFormField(
        decoration: const InputDecoration(
          labelText: null,
          border: OutlineInputBorder(),
        ),
        maxLength: 500,
        minLines: 5,
        maxLines: 10,
        initialValue: newDescription,
        onChanged: (value) => setState(() => newDescription = value),
        enabled: !(isSaving || showingPreview));

    var causeInput = TextFormField(
        decoration: const InputDecoration(
          hintText: "climate change, wellness, black-owned business, ...",
          border: OutlineInputBorder(),
        ),
        controller: causesTextController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9+ ,-]*"))
        ],
        minLines: 1,
        maxLines: 2,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: formatAndEnterCause,
        textCapitalization: TextCapitalization.none,
        enabled: !(isSaving || showingPreview));

    var causesDisplay = CausesChips(
        causes: causes,
        allowDeletion: true,
        onCauseDeleted: (cause) =>
            {causes.remove(cause), setState(() => causes = causes)});

    return ListView(shrinkWrap: true, primary: false, children: [
      Text("Banner Image", style: Theme.of(context).textTheme.headline4),
      bgSelection,
      const ListSpacer(),
      Text("Logo Image", style: Theme.of(context).textTheme.headline4),
      logoSelection,
      const ListSpacer(),
      Text("Mission Statement", style: Theme.of(context).textTheme.headline4),
      missionTextBox,
      const ListSpacer(),
      Text("Causes", style: Theme.of(context).textTheme.headline4),
      causeInput,
      causesDisplay,
      const ListSpacer(
        height: 50,
      )
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
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(children: [
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                primary: true,
                                child: showingPreview
                                    ? _buildPreview()
                                    : _buildMainPage()))
                      ])));
        });
  }
}
