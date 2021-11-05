import 'package:flutter/material.dart';
import 'package:community_app/models/user_model.dart';
import 'package:community_app/commands/get_user_account.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  static const routeName = '/users';

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoading = true;
  UserModel user = UserModel();

  void _loadUser() async {
    // Disable the RefreshBtn while the Command is running
    setState(() => _isLoading = true);
    // Run command

    var updated = await GetUserAccount().run(widget.userId);
    if (updated != null) {
      user = updated;
    }

    // Re-enable refresh btn when command is done
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading ? const Text('Loading') : Text(user.username),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadUser,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: (_isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  Text(user.name),
                  Text(user.email),
                ],
              )),
      ),
    );
  }
}
