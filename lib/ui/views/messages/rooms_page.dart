import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/ui/components/empty_result.dart';
import 'package:sagelink_communities/ui/views/messages/room_cell.dart';

class RoomsPage extends ConsumerStatefulWidget {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {
  List<Widget> roomList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<types.Room>>(
      stream: FirebaseChatCore.instance.rooms(),
      initialData: const [],
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
              bottom: 200,
            ),
            child: const EmptyResult(text: "No chats yet!"),
          );
        }

        return ListView.separated(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final room = snapshot.data![index];

            return RoomCell(room, onTap: () {});
          },
          separatorBuilder: (context, index) => const Divider(),
        );
      },
    );
  }
}
