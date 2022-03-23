import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/data/models/perk_model.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/universal_image_picker.dart';
import 'package:collection/collection.dart';

String createPerkMutation = """
mutation CreatePerks(\$input: [PerkCreateInput!]!) {
  createPerks(input: \$input) {
    perks {
      id
    }
  }
}
""";

String updatePerkMutation = """
mutation UpdatePerks(\$where: PerkWhere, \$update: PerkUpdateInput) {
  updatePerks(where: \$where, update: \$update) {
    perks {
      id
    }
  }
}
""";

typedef OnCompletionCallback = void Function();

List<PerkType> availablePerkTypes = [
  PerkType.exclusiveProduct,
  PerkType.freeGiveaway,
  PerkType.productDrop,
  PerkType.productTest
];

class NewPerkPage extends ConsumerStatefulWidget {
  const NewPerkPage(
      {Key? key, required this.brandId, required this.onCompleted})
      : super(key: key);
  final String brandId;
  final OnCompletionCallback onCompleted;

  static const routeName = '/shop';

  @override
  _NewPerkPageState createState() => _NewPerkPageState();
}

class _NewPerkPageState extends ConsumerState<NewPerkPage> {
  late final GraphQLClient client = ref.watch(gqlClientProvider).value;
  late FirebaseAnalytics analytics = ref.watch(analyticsProvider);

  final formKey = GlobalKey<FormState>();
  PerkModel _perk = PerkModel();

  bool isUpdating = false;
  bool isSaving = false;
  bool isDisposed = false;

  // NEEDS TO BE UPDATED IF NEW EXPANSION PANELS ARE ADDED
  List<bool> expansionState = [true, false, false, false];

  @override
  void dispose() {
    isDisposed = true;
    _imagePicker.clearImages();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      analytics.setCurrentScreen(screenName: "New Perk View");
      analytics.logScreenView(screenName: "New Perk View");
    });
  }

  int maxImages = 8;
  List<File> originalImageFiles = [];
  List<File> selectedImageFiles = [];
  late final UniversalImagePicker _imagePicker = UniversalImagePicker(
    context,
    maxImages: maxImages,
    onSelected: () {
      if (!isDisposed) {
        setState(() => selectedImageFiles = _imagePicker.images);
      }
    },
  );

  bool canSubmit() {
    return _perk.title.isNotEmpty &&
        _perk.type != PerkType.undefined &&
        _perk.description.isNotEmpty &&
        _perk.details.isNotEmpty &&
        _imagePicker.images.isNotEmpty &&
        _perk.redemptionUrl.isNotEmpty;
  }

  // Save logic

  void complete() {
    CustomWidgets.buildSnackBar(
        context, "Perk created!", SLSnackBarType.success);
    Navigator.of(context).pop();
    widget.onCompleted();
  }

  Future<bool> setImagesOnCreate(String perkId) async {
    ImageUploadResult imageResults = await _imagePicker
        .uploadImages("perk/$perkId/", context: context, client: client);
    if (!imageResults.success) {
      // Should delete post and/or retry
      return false;
    }
    var variables = {
      "where": {"id": perkId},
      "update": {"imageUrls": imageResults.locations}
    };
    QueryResult result = await client.mutate(MutationOptions(
        document: gql(updatePerkMutation), variables: variables));

    if (result.hasException) {
      // Should delete and/or retry
      return false;
    } else {
      return true;
    }
  }

  void createPerk() async {
    setState(() {
      isSaving = true;
    });
    bool success = true;

    Map<String, dynamic> mutationVariables = {
      "input": [
        {
          "title": _perk.title,
          "details": _perk.details,
          "description": _perk.description,
          "price": _perk.price,
          "productId": _perk.productId,
          "productName": _perk.productName,
          "redemptionUrl": _perk.redemptionUrl,
          "type": _perk.type.toShortString(),
          "inBrandCommunity": {
            "connect": {
              "where": {
                "node": {"id": widget.brandId}
              }
            }
          },
          "createdBy": {
            "connect": {
              "where": {
                "node": {"id": ref.read(loggedInUserProvider).getUser().id}
              }
            }
          }
        }
      ]
    };

    QueryResult result = await client.mutate(MutationOptions(
        document: gql(createPerkMutation), variables: mutationVariables));

    if (result.hasException) {
      success = false;
      CustomWidgets.buildSnackBar(context,
          "Error saving perk, please try again.", SLSnackBarType.error);
    }
    if (result.data != null) {
      if (_imagePicker.images.isNotEmpty) {
        bool uploadResult = await setImagesOnCreate(
            result.data!['createPerks']['perks'][0]['id']);

        if (!uploadResult) {
          success = false;
          CustomWidgets.buildSnackBar(context,
              "Error saving perk, please try again.", SLSnackBarType.error);
        }
      }
    }
    setState(() {
      isSaving = false;
    });

    analytics
        .logEvent(name: "perk_submit_click", parameters: {"status": success});

    if (success) {
      complete();
    }
  }

  // Build Widgets
  ExpansionPanel buildMainDetails() {
    List<Widget> optionalWidgets = [
      TextFormField(
        initialValue: _perk.price.toString(),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp("[0-9.]*"))
        ],
        maxLines: 2,
        minLines: 1,
        autofocus: true,
        onChanged: (value) => setState(() {
          _perk.price = num.tryParse(value) ?? 0;
        }),
        decoration: const InputDecoration(
          labelText: 'Price (\$)',
          hintText: "What price is this product?",
          //border: OutlineInputBorder(),
        ),
      ),
      TextFormField(
        initialValue: _perk.productName,
        maxLines: 1,
        minLines: 1,
        autofocus: true,
        onChanged: (value) => setState(() {
          _perk.productName = value;
        }),
        decoration: const InputDecoration(
          labelText: 'Product Name',
          hintText: "Product name... (e.g. on Shopify)",
        ),
      ),
      TextFormField(
        initialValue: _perk.productName,
        maxLines: 1,
        minLines: 1,
        autofocus: true,
        onChanged: (value) => setState(() {
          _perk.productId = value;
        }),
        decoration: const InputDecoration(
          labelText: 'Product ID',
          hintText: "Product ID... (e.g. on Shopify)",
          //border: OutlineInputBorder(),
        ),
      ),
    ];

    List<Widget> alwaysWidgets = [
      // type
      DropdownButton<String>(
        hint: const Text("Type"),
        value: _perk.type == PerkType.undefined
            ? null
            : _perk.type.toShortString(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            PerkType newType = PerkTypeManager.fromShortString(newValue);

            setState(() {
              if ([PerkType.freeGiveaway, PerkType.productTest]
                  .contains(newType)) {
                _perk.price = 0;
              }
              _perk.type = newType;
            });
          }
        },
        items:
            availablePerkTypes.map<DropdownMenuItem<String>>((PerkType value) {
          return DropdownMenuItem<String>(
            value: value.toShortString(),
            child: Text(value.displayString()),
          );
        }).toList(),
      ),
      const ListSpacer(height: 20),
      // title
      TextFormField(
        initialValue: _perk.title,
        maxLines: 2,
        minLines: 1,
        autofocus: true,
        onChanged: (value) => setState(() {
          _perk.title = value;
        }),
        decoration: const InputDecoration(
          labelText: 'Title',
          hintText: "Enter a descriptive title...",
          //border: OutlineInputBorder(),
        ),
      ),
      const ListSpacer(height: 20),
      // redeem url
      TextFormField(
        initialValue: _perk.redemptionUrl,
        maxLines: 1,
        minLines: 1,
        autofocus: true,
        keyboardType: TextInputType.url,
        onChanged: (value) => setState(() {
          _perk.redemptionUrl = value;
        }),
        decoration: const InputDecoration(
          labelText: "Redemption URL",
          hintText: "Enter the url a user should be directed to...",
          border: OutlineInputBorder(),
        ),
      )
    ];

    // if (_perk.type == PerkType.productDrop) {
    //   showDatePicker(context: context, initialDate: initialDate, firstDate: firstDate, lastDate: lastDate)
    // }

    Widget leftCol = Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: alwaysWidgets));
    Widget rightCol = Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: optionalWidgets));
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return const ListTile(
          title: Text('Overview'),
        );
      },
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Expanded(child: leftCol), Expanded(child: rightCol)],
      ),
      isExpanded: expansionState[0],
    );
  }

  ExpansionPanel buildDescriptionTextBox() {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return const ListTile(
          title: Text('Description'),
        );
      },
      body: Container(
          padding: const EdgeInsets.all(20),
          child: TextFormField(
            initialValue: _perk.description,
            maxLines: 10,
            minLines: 7,
            onChanged: (value) => setState(() {
              _perk.description = value;
            }),
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: "Add a description of the product and the perk...",
              border: OutlineInputBorder(),
            ),
          )),
      isExpanded: expansionState[1],
    );
  }

  ExpansionPanel buildDetailsTextBox() {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return const ListTile(
          title: Text('Details'),
        );
      },
      body: Container(
          padding: const EdgeInsets.all(20),
          child: TextFormField(
            initialValue: _perk.description,
            maxLines: 10,
            minLines: 7,
            onChanged: (value) => setState(() {
              _perk.details = value;
            }),
            decoration: const InputDecoration(
              labelText: 'Details',
              hintText:
                  "Add additional details to help your customers redeem...",
              border: OutlineInputBorder(),
            ),
          )),
      isExpanded: expansionState[2],
    );
  }

  ExpansionPanel buildImagesBox() {
    Widget addImageContainer = InkWell(
        onTap: _imagePicker.openImagePicker,
        child: Container(
          width: 150,
          height: 150,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Theme.of(context).dividerColor)),
          child:
              const Align(alignment: Alignment.center, child: Icon(Icons.add)),
        ));

    List<Widget> imageList = selectedImageFiles
        .mapIndexed((index, im) => Container(
            width: 150,
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Theme.of(context).dividerColor)),
            child: Stack(alignment: Alignment.topLeft, children: [
              SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: kIsWeb
                      ? Image.network(
                          im.path,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          im,
                          fit: BoxFit.cover,
                        )),
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
                          child: IconButton(
                              iconSize: 18,
                              onPressed: () =>
                                  _imagePicker.removeImageAtIndex(index),
                              icon: const Icon(Icons.delete_outline)))))
            ])))
        .toList();
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return const ListTile(
          title: Text('Images'),
        );
      },
      body: Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: selectedImageFiles.length >= maxImages
                ? imageList
                : [...imageList, addImageContainer],
          )),
      isExpanded: expansionState[3],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Create Perk"),
          actions: [buildSubmit(enabled: canSubmit())],
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0),
      body: Form(
          key: formKey,
          //autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  constraints:
                      const BoxConstraints(maxWidth: 800, minWidth: 300),
                  child: ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) {
                        print(isExpanded);
                        setState(() {
                          expansionState[panelIndex] = !isExpanded;
                        });
                      },
                      children: [
                        buildMainDetails(),
                        buildDescriptionTextBox(),
                        buildDetailsTextBox(),
                        buildImagesBox(),
                      ])),
            ],
          )),
    );
  }

  Widget buildSubmit({bool enabled = true}) => Builder(
      builder: (context) => Mutation(
          options: MutationOptions(
              document: gql(createPerkMutation),
              onCompleted: (dynamic resultData) {
                widget.onCompleted();
                Navigator.pop(context);
              }),
          builder: (RunMutation runMutation, result) => IconButton(
                icon: const Icon(Icons.send),
                onPressed: enabled ? createPerk : null,
              )));
}
