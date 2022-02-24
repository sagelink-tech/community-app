import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/views/messages/chat_page.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  late final userService = ref.watch(userServiceProvider);
  List<UserModel> users = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? searchText;

  late List<UserModel> filteredUsers = searchText != null
      ? users
          .where((element) =>
              element.name.toLowerCase().contains(searchText!.toLowerCase()))
          .toList()
      : users;

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text("Select a user to message");

  void updateSearchText(String? text) {
    var _filteredUsers = text != null
        ? users
            .where((element) =>
                element.name.toLowerCase().contains(text.toLowerCase()))
            .toList()
        : users;
    setState(() {
      filteredUsers = _filteredUsers;
      searchText = text;
    });
  }

  void toggleSearch() {
    var icon = _isSearching
        ? const Icon(Icons.search_outlined)
        : const Icon(Icons.cancel_outlined);

    var searchBar = _isSearching
        ? const Text("Select a user to message")
        : TextFormField(
            autofocus: true,
            initialValue: searchText,
            onChanged: updateSearchText,
            decoration: const InputDecoration(
              hintText: "Search for a user...",
            ),
          );

    setState(() {
      _isSearching = !_isSearching;
      customIcon = icon;
      customSearchBar = searchBar;
      searchText = null;
      filteredUsers = users;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      final _users = await userService.fetchMessagebleUers();
      setState(() {
        users = _users;
        _isLoading = false;
      });
    });
  }

  void _handlePressed(UserModel otherUser, BuildContext context) async {
    types.User user = types.User(id: otherUser.firebaseId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                onPressed: toggleSearch,
                icon: customIcon,
              )
            ],
            title: customSearchBar,
            elevation: 0,
            backgroundColor: Theme.of(context).backgroundColor),
        body: _isLoading
            ? const Loading()
            : ListView.separated(
                itemCount: filteredUsers.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    key: Key(user.id),
                    leading: ClickableAvatar(
                        avatarText: user.name[0],
                        avatarImage: user.profileImage()),
                    title: Text(user.name),
                    onTap: () {
                      _handlePressed(user, context);
                    },
                  );
                },
              ));
  }
}
