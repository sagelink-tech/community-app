import 'package:sagelink_communities/ui/components/empty_result.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/ui/views/users/user_cell.dart';
import 'package:flutter/material.dart';

class UserListView extends StatelessWidget {
  final List<UserModel> users;

  const UserListView(this.users, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render list of widgets

    return users.isNotEmpty
        ? ListView.separated(
            itemCount: users.length,
            cacheExtent: 20,
            controller: ScrollController(),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => UserCell(
                  index,
                  users[index],
                ))
        : const EmptyResult(text: "Looks like no users just yet...");
  }
}
