import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/user_model.dart';

class UserCell extends StatelessWidget {
  final int itemNo;
  final UserModel user;

  const UserCell(this.itemNo, this.user, {Key? key}) : super(key: key);

  void _handleClick(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: user.id)));
    return;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClickableAvatar(
        avatarText: user.initials,
        avatarImage: user.profileImage(),
      ),
      title: Text(user.name, style: Theme.of(context).textTheme.headline6),
      subtitle: user.runtimeType == EmployeeModel
          ? Text((user as EmployeeModel).jobTitle,
              style: Theme.of(context).textTheme.caption)
          : null,
      trailing: IconButton(
          onPressed: () => _handleClick(context),
          icon: const Icon(Icons.arrow_forward_outlined)),
    );
  }
}
