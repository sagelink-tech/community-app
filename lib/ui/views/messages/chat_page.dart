import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    Key? key,
    required this.room,
  }) : super(key: key);

  final types.Room room;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final userService = ref.watch(userServiceProvider);
  late final loggedInUserId = ref.watch(
      loggedInUserProvider.select((value) => value.getUser().firebaseId));

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

  UserModel getOtherUser() {
    final user = users.firstWhere(
        (element) => element.firebaseId != loggedInUserId,
        orElse: () => UserModel());
    return user;
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  void _goToAccount(String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    UserModel otherUser = getOtherUser();
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: InkWell(
            onTap: () => _goToAccount(otherUser.id),
            child: Row(children: [
              ClickableAvatar(
                  avatarText:
                      otherUser.name.isNotEmpty ? otherUser.name[0] : "",
                  avatarImage: otherUser.profileImage()),
              const ListSpacer(width: 10),
              Text(otherUser.name),
            ])),
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: StreamBuilder<types.Room>(
        initialData: widget.room,
        stream: FirebaseChatCore.instance.room(widget.room.id),
        builder: (context, snapshot) {
          return StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: FirebaseChatCore.instance.messages(snapshot.data!),
            builder: (context, snapshot) {
              return SafeArea(
                bottom: false,
                child: Chat(
                  theme: DefaultChatTheme(
                      errorColor: Theme.of(context).colorScheme.error,
                      inputBackgroundColor: Theme.of(context).backgroundColor,
                      inputTextColor: Theme.of(context).colorScheme.secondary,
                      inputContainerDecoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).dividerColor,
                              offset: const Offset(0, -2),
                              blurRadius: 5.0)
                        ],
                      ),
                      inputTextCursorColor:
                          Theme.of(context).colorScheme.secondary,
                      inputBorderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      primaryColor: Theme.of(context).colorScheme.primary),
                  messages: snapshot.data ?? [],
                  onSendPressed: _handleSendPressed,
                  user: types.User(
                    id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
