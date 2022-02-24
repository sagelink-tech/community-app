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
            title: const Text("Select a user to message"),
            elevation: 0,
            backgroundColor: Theme.of(context).backgroundColor),
        body: _isLoading
            ? const Loading()
            : ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
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
