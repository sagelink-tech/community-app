import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat_page.dart';

class RoomCell extends ConsumerStatefulWidget {
  const RoomCell(this.room, {required this.onTap, Key? key}) : super(key: key);
  final types.Room room;
  final VoidCallback onTap;

  @override
  _RoomCellState createState() => _RoomCellState();
}

class _RoomCellState extends ConsumerState<RoomCell> {
  late final userService = ref.watch(userServiceProvider);
  late final loggedInUserId = ref.watch(
      loggedInUserProvider.select((value) => value.getUser().firebaseId));
  List<UserModel> users = [];

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      final _users = await userService.fetchUserDisplayData(
          firebaseIds: widget.room.users.map((e) => e.id).toList());
      if (!_isDisposed) {
        setState(() {
          users = _users ?? [];
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  UserModel getOtherUser() {
    final user = users.firstWhere(
        (element) => element.firebaseId != loggedInUserId,
        orElse: () => UserModel());
    return user;
  }

  Widget timestamp() {
    String timeString = "";
    if (widget.room.updatedAt != null) {
      timeString = " · " +
          timeago.format(
              DateTime.fromMillisecondsSinceEpoch(widget.room.updatedAt!),
              locale: "en_short");
    }
    return Text(timeString, style: Theme.of(context).textTheme.caption);
  }

  Widget subtitle() {
    String textString = "";

    if (widget.room.lastMessages != null &&
        widget.room.lastMessages!.isNotEmpty) {
      types.Message lastMessage = widget.room.lastMessages![0];
      textString = lastMessage.author.id == loggedInUserId ? "You: " : "";
      switch (lastMessage.type) {
        case types.MessageType.custom:
          textString += "sent a message";
          break;
        case types.MessageType.file:
          textString += "sent an attachment";
          break;
        case types.MessageType.image:
          textString += "sent an image";
          break;
        case types.MessageType.text:
          textString += (lastMessage as types.TextMessage).text;
          break;
        case types.MessageType.unsupported:
          textString += "sent a message";
          break;
      }
    }
    return Text(
      textString,
      softWrap: true,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.caption,
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = getOtherUser();
    return ListTile(
        leading: ClickableAvatar(
            avatarText: user.name.isNotEmpty ? user.name[0] : "",
            avatarImage: user.profileImage()),
        trailing: const Icon(Icons.arrow_forward_outlined),
        title: Row(children: [Text(user.name), timestamp()]),
        subtitle: subtitle(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatPage(
                room: widget.room,
              ),
            ),
          );

          widget.onTap();
        });
  }
}
