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
  late final userService = ref.watch(userServiceProvider);
  late final client = ref.watch(gqlClientProvider).value;
  late final analytics = ref.watch(analyticsProvider);

  late UserModel user = loggedInUser.getUser();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      analytics.setCurrentScreen(screenName: "Profile Creation View");
      analytics.logScreenView(screenName: "Profile Creation View");
    });
  }

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

  Future<void> uploadAndSavePhoto(
      BuildContext context, GraphQLClient client, String userId) async {
    if (_profileImagePicker.images.isNotEmpty) {
      // upload logo image
      var imageResult = await _profileImagePicker.uploadImages("users/$userId/",
          imageKeyPrefix: "logo", context: context, client: client);
      if (!imageResult.success) {
        setState(() {
          _isSaving = false;
        });
      } else {
        await userService.updateUserWithID(
            userId, {"accountPictureUrl": imageResult.locations[0]},
            requireAuth: false);
      }
    }
  }

  // Save changes
  void _saveChanges(BuildContext context) async {
    analytics.logEvent(name: "user_creation");

    // Start saving
    setState(() {
      _isSaving = true;
    });
    // Step one: create the user
    user.name = newName;
    user.description = newDescription;
    user.causes = newCauses;

    if (_profileImagePicker.images.isNotEmpty) {
      user.accountPictureUrl = "";
    }

    notifier.createNewUser(user, onComplete: (data) async {
      String? userId;
      if (data != null && (data!['createUsers']['users'] as List).isNotEmpty) {
        userId = data!['createUsers']['users'][0]['id'];
      }

      if (_profileImagePicker.images.isNotEmpty && userId != null) {
        await uploadAndSavePhoto(context, client, userId);
      }
      setState(() {
        _isSaving = false;
      });
    });
  }

  TextEditingController causesTextController = TextEditingController();
  // Text controller functions
  void formatAndEnterCause(String value) {
    List<CauseModel> _newCauses = value.split(',').map((element) {
      element.trim();
      return CauseModel("tmp_" + element, element.toLowerCase().trim());
    }).toList();

    setState(() {
      newCauses = _newCauses;
    });
    causesTextController.clear();
  }

  // Build editable components
  Widget _buildProfileImage() {
    Widget avatar = ClickableAvatar(
      avatarText: user.initials,
      avatarImage: (newProfileImage ?? user.profileImage()),
      radius: 58,
      onTap: () => _profileImagePicker.openImagePicker(),
    );
    return Row(
      children: [
        avatar,
        const ListSpacer(width: 25),
        OutlinedButton(
            style: OutlinedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                minimumSize: const Size(163, 56)),
            onPressed: () => _profileImagePicker.openImagePicker(),
            child: const Text("Select photo"))
      ],
    );
  }

  bool canSubmit() {
    return !_isSaving && newName.isNotEmpty;
  }

  Widget _buildSubmit() {
    return Visibility(
        visible: canSubmit(),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.onSecondary,
              minimumSize: const Size.fromHeight(48)),
          onPressed: canSubmit() ? () => _saveChanges(context) : null,
          child: Text("Create profile",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  color: Theme.of(context).colorScheme.onError)),
        ));
  }

  Widget _buildNameText() {
    return TextFormField(
        decoration: const InputDecoration(
          labelText: null,
          hintText: "How others will see your name...",
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
        style: Theme.of(context).textTheme.headline5,
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
          hintText: "climate change, wellness, black-owned business, ...",
          border: OutlineInputBorder(),
        ),
        controller: causesTextController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9+ ,-]*"))
        ],
        maxLength: 100,
        minLines: 1,
        maxLines: 2,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: formatAndEnterCause,
        textCapitalization: TextCapitalization.none);

    var causesDisplay = CausesChips(
        causes: newCauses,
        allowDeletion: true,
        onCauseDeleted: (cause) =>
            {newCauses.remove(cause), setState(() => newCauses = newCauses)});

    return [
      const ListSpacer(
        height: 10,
      ),
      Text(
        "Causes",
        style: Theme.of(context).textTheme.headline5,
      ),
      const ListSpacer(
        height: 10,
      ),
      causeInput,
      causesDisplay
    ];
  }

  // Build main view
  _buildHeader(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline2,
          ),
          _buildProfileImage(),
          const ListSpacer(height: 20),
          Text(
            "Your name",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline5,
          ),
          const ListSpacer(height: 10),
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
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor, elevation: 0),
        body: _isSaving
            ? const Loading()
            : Stack(alignment: Alignment.bottomCenter, children: [
                ListView(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 70),
                  children: [_buildHeader(context), _buildBody(context)],
                ),
                _buildSubmit()
              ]));
  }
}
