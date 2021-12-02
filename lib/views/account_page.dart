import 'package:flutter/material.dart';
import 'package:community_app/models/user_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getUserQuery = """
query Users(\$where: UserWhere) {
  users(where: \$where) {
    id
    username
    email
    name
  }
}
""";

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  static const routeName = '/users';

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserModel _user = UserModel();

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(getUserQuery),
          variables: {
            "where": {"id": widget.userId},
            "options": {"limit": 1}
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            _user = UserModel.fromJson(result.data?['users'][0]);
          }
          return Scaffold(
            appBar: AppBar(
                title: result.isLoading || result.hasException
                    ? const Text('')
                    : Text(_user.username),
                actions: [
                  IconButton(
                    onPressed: result.isLoading ? null : refetch,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
                backgroundColor: Theme.of(context).backgroundColor,
                elevation: 0),
            body: Center(
              child: (result.hasException
                  ? Text(result.exception.toString())
                  : result.isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            Text(_user.name),
                            Text(_user.email),
                          ],
                        )),
            ),
          );
        });
  }
}
