import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:sagelink_communities/data/models/cause_model.dart';
import 'package:sagelink_communities/ui/components/brand_chip.dart';
import 'package:sagelink_communities/ui/components/causes_chips.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/components/moderation_options_sheet.dart';
import 'package:sagelink_communities/ui/components/universal_image_picker.dart';
import 'package:sagelink_communities/ui/views/messages/chat_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

String getUserQuery = """
query UsersQuery(\$where: UserWhere, \$options: UserOptions) {
  users(where: \$where, options: \$options) {
    name
    id
    description
    accountPictureUrl
    queryUserHasBlocked
    queryUserIsBlocked
    firebaseId
    memberOfBrands {
      id
      name
      logoUrl
      mainColor
    }
    causes {
      title
      id
    }
    employeeOfBrands {
      id
      name
      logoUrl
      mainColor  
    }
  }
}
""";

String updateUserMutation = """
mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput, \$connectOrCreate: UserConnectOrCreateInput, \$disconnect: UserDisconnectInput) {
  updateUsers(where: \$where, update: \$update, connectOrCreate: \$connectOrCreate, disconnect: \$disconnect) {
    users {
      id
    }
  }
}
""";

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  static const routeName = '/users';

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  UserModel _user = UserModel();
  late final loggedInUser = ref.watch(loggedInUserProvider);
  bool _isLoggedInUser() {
    return _user.id == loggedInUser.getUser().id;
  }

  bool _isSaving = false;
  bool _isEditing = false;
  void _toggleEditing() {
    if (!_isLoggedInUser()) {
      return;
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<UserModel?> _getUser(GraphQLClient client) async {
    //client.resetStore();
    Map<String, dynamic> variables = {
      "where": {"id": widget.userId},
      "options": {"limit": 1}
    };

    QueryResult result = await client
        .query(QueryOptions(document: gql(getUserQuery), variables: variables));
    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      return UserModel.fromJson(result.data?['users'][0]);
    }
    return null;
  }

  // Editing data
  late String newDescription = _user.description;
  late String newName = _user.name;
  Image? newProfileImage;
  late List<CauseModel> newCauses = _user.causes;

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
        newProfileImage = null;
      });
    }
  }

  void _showOptionsModal(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return ModerationOptionsSheet(
            ModerationOptionSheetType.user,
            user: _user,
            onComplete: () => setState(() {}),
          );
        });
  }

  // Save changes

  Future<bool> _saveChanges(BuildContext context, GraphQLClient client) async {
    // No changes to make
    if (!_isLoggedInUser()) {
      return false;
    }

    // Start saving
    setState(() {
      _isSaving = true;
    });

    var updateData = {
      "description": newDescription,
      "name": newName,
    };

    // parse causes
    var newCausesSet = newCauses.toSet();
    var oldCausesSet = _user.causes.toSet();
    var causesToRemove = oldCausesSet.difference(newCausesSet).toList();
    var causesToAdd = newCausesSet.difference(oldCausesSet).toList();

    // initialize mutation variables
    var mutationVariables = {
      "where": {"id": _user.id},
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

    if (newProfileImage != null) {
      // upload logo image
      var imageResult = await _profileImagePicker.uploadImages(
          "users/${_user.id}/",
          imageKeyPrefix: "logo",
          context: context,
          client: client);

      if (!imageResult.success) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
        return false;
      } else {
        updateData["accountPictureUrl"] = imageResult.locations[0];
      }
    }

    mutationVariables["update"] = updateData;

    // Update
    MutationOptions options = MutationOptions(
        document: gql(updateUserMutation), variables: mutationVariables);

    QueryResult result = await client.mutate(options);

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    return !result.hasException &&
        result.data!['updateUsers']['users'][0]['id'] == _user.id;
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
      avatarText: _user.name[0],
      avatarImage: _isEditing
          ? (newProfileImage ?? _user.profileImage())
          : _user.profileImage(),
      radius: _isEditing ? 58 : 60,
      onTap: _isEditing ? () => _profileImagePicker.openImagePicker() : null,
    );
    return _isEditing
        ? DottedBorder(
            borderType: BorderType.Circle,
            radius: const Radius.circular(10),
            dashPattern: const [5],
            color: Theme.of(context).primaryColor,
            child: Container(
                alignment: Alignment.center,
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                ),
                child: avatar))
        : avatar;
  }

  Widget _buildNameText() {
    return _isEditing
        ? TextFormField(
            decoration: const InputDecoration(
              labelText: null,
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 1,
            initialValue: newName,
            onChanged: (value) => setState(() => newName = value))
        : Text(_user.name,
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.start);
  }

  List<Widget> _buildDescriptionComponents() {
    List<Widget> components = [
      Text(
        "Description",
        style: Theme.of(context).textTheme.headline4,
      ),
      const ListSpacer(),
      const ListSpacer()
    ];
    components.insert(
        2,
        _isEditing
            ? TextFormField(
                decoration: const InputDecoration(
                  labelText: null,
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                initialValue: newDescription,
                onChanged: (value) => setState(() => newDescription = value))
            : Text(
                _user.description,
                style: Theme.of(context).textTheme.caption,
              ));
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

    List<Widget> components = _isEditing || _user.causes.isNotEmpty
        ? [
            Text(
              "Causes",
              style: Theme.of(context).textTheme.headline4,
            )
          ]
        : [];

    if (_isEditing) {
      components.addAll([causeInput, causesDisplay]);
    } else if (_user.causes.isNotEmpty) {
      components.add(CausesChips(causes: _user.causes));
    }
    return components;
  }

  // Build uneditable components
  bool canMessage() => !(_isLoggedInUser() ||
      _user.queryUserHasBlocked ||
      _user.queryUserIsBlocked);

  void _handleMessagePressed() async {
    types.User user = types.User(id: _user.firebaseId);
    final room = await FirebaseChatCore.instance.createRoom(user);

    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
  }

  List<Widget> _buildMessageButton() {
    return canMessage()
        ? [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                  // onPrimary: Theme.of(context).colorScheme.onSecondary,
                  minimumSize: const Size.fromHeight(48)),
              onPressed: _handleMessagePressed,
              child: Text('Message',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.onError)),
            ),
            const ListSpacer(height: 20)
          ]
        : [];
  }

  List<Widget> _buildMembershipComponents() {
    return _isEditing
        ? []
        : [
            Text(
              "Member at",
              style: Theme.of(context).textTheme.headline4,
            ),
            const ListSpacer(),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: _user.brands
                  .map((b) => BrandChip(brand: b, onTap: (brand) => {}))
                  .toList(),
            ),
            const ListSpacer()
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
          ..._buildMessageButton()
        ]);
  }

  _buildBody(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildDescriptionComponents(),
          ..._buildMembershipComponents(),
          ..._buildCauseComponents()
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return FutureBuilder(
          future: _getUser(client),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _user = snapshot.data;
            } else if (snapshot.hasError) {
              //TO DO: DEBUG THIS ERROR
            }
            return Scaffold(
                appBar: AppBar(
                    title: null,
                    actions: _isLoggedInUser() && !_isSaving
                        ? [
                            IconButton(
                              onPressed: () => _isEditing
                                  ? _saveChanges(context, client)
                                  : _toggleEditing(),
                              icon: Icon(_isEditing ? Icons.done : Icons.edit),
                            )
                          ]
                        : [
                            IconButton(
                                onPressed: () => _showOptionsModal(context),
                                icon: const Icon(Icons.more_horiz_outlined))
                          ],
                    backgroundColor: Theme.of(context).backgroundColor,
                    elevation: 0),
                body: (snapshot.hasData
                    ? _isSaving
                        ? const Loading()
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildHeader(context),
                              _buildBody(context)
                            ],
                          )
                    : snapshot.hasError
                        ? const ErrorView()
                        : const Loading()));
          });
    });
  }
}
