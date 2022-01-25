import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/pages/account_page.dart';
import 'package:timeago/timeago.dart' as timeago;

String getMembersQuery = """
query Users(\$where: UserWhere, \$options: UserOptions) {
  users(where: \$where, options: \$options) {
    id
    email
    description
    name
    accountPictureUrl
    createdAt
    memberOfBrandsConnection {
      edges {
        tier
      }
    }
  }
}
""";

class AdminMembersPage extends ConsumerStatefulWidget {
  const AdminMembersPage({Key? key}) : super(key: key);

  @override
  _AdminMembersPageState createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends ConsumerState<AdminMembersPage> {
  List<MemberModel> _members = [];

  void _goToAccount(String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = ref.watch(loggedInUserProvider);
    //String? searchText;

    Future<List<MemberModel>> fetchMembers(GraphQLClient client) async {
      Map<String, dynamic> variables = {
        "where": {
          "memberOfBrands": {"id": loggedInUser.adminBrandId}
        },
        "options": {
          "sort": [
            {"createdAt": "ASC", "name": "ASC"}
          ]
        }
      };

      List<MemberModel> members = [];
      QueryResult result = await client.query(
          QueryOptions(document: gql(getMembersQuery), variables: variables));
      if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
        members = (result.data!['users'] as List)
            .map((u) => MemberModel.fromJson(u))
            .toList();
      }
      return members;
    }

    Widget _buildUserTable() {
      return Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Member',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Member since',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tier',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ], rows: <DataRow>[
                    ..._members.map((e) => DataRow(cells: <DataCell>[
                          DataCell(
                              Row(children: [
                                ClickableAvatar(
                                  avatarText: e.name,
                                  avatarURL: e.accountPictureUrl,
                                  radius: 30,
                                ),
                                const ListSpacer(),
                                Text(e.name)
                              ]),
                              onTap: () => {_goToAccount(e.id)}),
                          DataCell(Text(e.email)),
                          DataCell(Text(timeago.format(e.createdAt))),
                          DataCell(Text(e.tier)),
                        ]))
                  ]))));
    }

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return FutureBuilder(
          future: fetchMembers(client),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _members = snapshot.data;
            } else if (snapshot.hasError) {
              //TO DO: DEBUG THIS ERROR
            }
            return Container(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          flex: 6,
                          child: Text("Search Bar Here"),
                        ),
                        const Spacer(),
                        const Flexible(
                          flex: 3,
                          child: Text("Filters here"),
                        ),
                        const Spacer(),
                        Flexible(
                            flex: 3,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary:
                                        Theme.of(context).colorScheme.secondary,
                                    onPrimary:
                                        Theme.of(context).colorScheme.onError),
                                onPressed: () => {},
                                child: const Text("Invite")))
                      ],
                    ),
                    Center(
                        child: Text(
                      _members.length.toString() + " results",
                      style: Theme.of(context).textTheme.caption,
                    )),
                    Expanded(
                      child: _buildUserTable(),
                    ),
                  ],
                ));
          });
    });
  }
}
