import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:sagelink_communities/data/models/cause_model.dart';
import 'package:sagelink_communities/ui/components/causes_chips.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/components/universal_image_picker.dart';

class UserCreationPage extends ConsumerStatefulWidget {
  const UserCreationPage({Key? key}) : super(key: key);

  @override
  _UserCreationPageState createState() => _UserCreationPageState();
}

class _UserCreationPageState extends ConsumerState<UserCreationPage> {
  late final loggedInUser = ref.watch(loggedInUserProvider);
  late final notifier = ref.watch(loggedInUserProvider.notifier);

  late UserModel user = loggedInUser.getUser();

  bool _isSaving = false;

  // Editing data
  late String newDescription = user.description;
  late String newName = user.name;
  Image? newProfileImage;
  late List<CauseModel> newCauses = user.causes;

  late final UniversalImagePicker _profileImagePicker = UniversalImagePicker(
      context,
      maxImages: 1,
      onSelected: _updateProfileImage);

  void _updateProfileImage() {
    if (_profileImagePicker.images.isNotEmpty) {
      setState(() {
        newProfileImage =
            Image.file(_profileImagePicker.images.first, fit: BoxFit.fitWidth);
      });
    } else {
      setState(() {
        newProfileImage = user.profileImage();
      });
    }
  }

  // Save changes

  void _saveChanges(BuildContext context, GraphQLClient client) async {
    // Start saving
    setState(() {
      _isSaving = true;
    });

    if (user.accountPictureUrl.isNotEmpty ||
        _profileImagePicker.images.isNotEmpty) {
      // upload logo image
      var imageResult = await _profileImagePicker.uploadImages(
          "users/${user.id}/",
          imageKeyPrefix: "logo",
          context: context,
          client: client);

      if (!imageResult.success) {
        setState(() {
          _isSaving = false;
        });
      } else {
        user.accountPictureUrl = imageResult.locations[0];
      }
    }

    user.name = newName;
    user.description = newDescription;
    user.causes = newCauses;

    notifier.createNewUser(user,
        onComplete: (data) => {
              setState(() {
                _isSaving = false;
              }),
              print("Should go to brand verify page")
            });
  }

  TextEditingController causesTextController = TextEditingController();
  // Text controller functions
  void formatAndEnterCause(String value) {
    newCauses.add(
        CauseModel("tmp_" + newCauses.length.toString(), value.toLowerCase()));
    setState(() {
      newCauses = newCauses;
    });
    causesTextController.clear();
  }

  // Build editable components
  Widget _buildProfileImage() {
    Widget avatar = ClickableAvatar(
      avatarText: user.name.isNotEmpty ? user.name[0] : user.email[0],
      avatarImage: (newProfileImage ?? user.profileImage()),
      radius: 58,
      onTap: () => _profileImagePicker.openImagePicker(),
    );
    return DottedBorder(
        borderType: BorderType.Circle,
        radius: const Radius.circular(10),
        dashPattern: const [5],
        color: Theme.of(context).primaryColor,
        child: Container(
            alignment: Alignment.center,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
            ),
            child: avatar));
  }

  Widget _buildNameText() {
    return TextFormField(
        decoration: const InputDecoration(
          labelText: null,
          hintText: "Your name",
          border: OutlineInputBorder(),
        ),
        minLines: 1,
        maxLines: 1,
        initialValue: newName,
        onChanged: (value) => setState(() => newName = value));
  }

  List<Widget> _buildDescriptionComponents() {
    List<Widget> components = [
      Text(
        "Description",
        style: Theme.of(context).textTheme.headline4,
      ),
      const ListSpacer(),
      TextFormField(
          decoration: const InputDecoration(
            labelText: null,
            hintText:
                "Add a bio to share with other members in your communities...",
            border: OutlineInputBorder(),
          ),
          minLines: 3,
          maxLines: 5,
          initialValue: newDescription,
          onChanged: (value) => setState(() => newDescription = value)),
      const ListSpacer()
    ];
    return components;
  }

  List<Widget> _buildCauseComponents() {
    var causeInput = TextFormField(
        decoration: const InputDecoration(
          hintText: "Type a cause then hit enter",
          border: OutlineInputBorder(),
        ),
        controller: causesTextController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9+ \n]*"))
        ],
        maxLength: 20,
        minLines: 1,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: formatAndEnterCause,
        textCapitalization: TextCapitalization.none);

    var causesDisplay = CausesChips(
        causes: newCauses,
        allowDeletion: true,
        onCauseDeleted: (cause) =>
            {newCauses.remove(cause), setState(() => newCauses = newCauses)});

    return [
      Text(
        "Causes",
        style: Theme.of(context).textTheme.headline4,
      ),
      causeInput,
      causesDisplay
    ];
  }

  // Build main view
  _buildHeader(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileImage(),
          const ListSpacer(height: 20),
          _buildNameText(),
          const ListSpacer(height: 20),
        ]);
  }

  _buildBody(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildDescriptionComponents(),
          ..._buildCauseComponents()
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
          appBar: AppBar(
              title: const Text("Setup Your Profile"),
              actions: [
                IconButton(
                  onPressed: () => _saveChanges(context, client),
                  icon: const Icon(Icons.done),
                )
              ],
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 0),
          body: _isSaving
              ? const Loading()
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [_buildHeader(context), _buildBody(context)],
                ));
    });
  }
}
