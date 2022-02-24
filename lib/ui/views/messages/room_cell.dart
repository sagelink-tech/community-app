import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      final _users = await userService.fetchUserDisplayData(
          firebaseIds: widget.room.users.map((e) => e.id).toList());
      setState(() {
        users = _users ?? [];
      });
    });
  }

  UserModel getOtherUser() {
    final user = users.firstWhere(
        (element) => element.firebaseId != loggedInUserId,
        orElse: () => UserModel());
    return user;
  }

  @override
  Widget build(BuildContext context) {
    var user = getOtherUser();
    return ListTile(
        leading: ClickableAvatar(
            avatarText: user.name.isNotEmpty ? user.name[0] : "",
            avatarImage: user.profileImage()),
        title: Text(user.name),
        // subtitle: widget.room.updatedAt != null
        //     ? Text(timeago.format(
        //         DateTime.fromMillisecondsSinceEpoch(widget.room.updatedAt!)))
        //     : null,
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
