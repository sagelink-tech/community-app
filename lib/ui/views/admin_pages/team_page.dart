import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/invite_model.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';
import 'package:sagelink_communities/ui/views/users/invite_page.dart';
import 'package:timeago/timeago.dart' as timeago;

String getEmployeesQuery = """
query Users(\$where: UserWhere, \$options: UserOptions, \$inviteWhere: InviteWhere, \$inviteOptions: InviteOptions) {
  users(where: \$where, options: \$options) {
    id
    description
    name
    accountPictureUrl
    createdAt
    employeeOfBrandsConnection {
      edges {
        roles
        founder
        owner
        jobTitle
        inviteEmail
        createdAt
        updatedAt
      }
    }
  }
  invites(where: \$inviteWhere, options: \$inviteOptions) {
    id
    verificationCode
    userEmail
    isAdmin
    createdAt
    jobTitle
    roles
    founder
    owner
    forBrand {
      id
    }
  }
}
""";

class AdminTeamPage extends ConsumerStatefulWidget {
  const AdminTeamPage({Key? key}) : super(key: key);

  @override
  _AdminTeamPageState createState() => _AdminTeamPageState();
}

class _AdminTeamPageState extends ConsumerState<AdminTeamPage> {
  List<EmployeeModel> _employees = [];
  List<EmployeeInviteModel> _invites = [];

  bool _showingInvites = false;

  late final loggedInUser = ref.watch(loggedInUserProvider);
  late final userService = ref.watch(userServiceProvider);

  void _toggleShowingInvites() {
    setState(() {
      _showingInvites = !_showingInvites;
    });
  }

  void _showInviteOption() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const FractionallySizedBox(
              heightFactor: 0.85,
              child: InvitePage(inviteType: InviteType.teammates));
        });
  }

  void _goToAccount(String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  Future<dynamic> fetchTeamAndInvites(GraphQLClient client) async {
    Map<String, dynamic> variables = {
      "where": {
        "employeeOfBrands": {"id": loggedInUser.adminBrandId}
      },
      "options": {
        "sort": [
          {"createdAt": "ASC", "name": "ASC"}
        ]
      },
      "inviteWhere": {
        "forBrand": {"id": loggedInUser.adminBrandId},
        "isAdmin": true
      },
      "inviteOptions": {
        "sort": [
          {"createdAt": "ASC", "userEmail": "ASC"}
        ]
      }
    };

    List<EmployeeModel> employees = [];
    List<EmployeeInviteModel> invites = [];
    QueryResult result = await client.query(
        QueryOptions(document: gql(getEmployeesQuery), variables: variables));

    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      employees = (result.data!['users'] as List)
          .map((u) => EmployeeModel.fromJson(u))
          .toList();
    }
    if (result.data != null && (result.data!['invites'] as List).isNotEmpty) {
      invites = (result.data!['invites'] as List)
          .map((u) => EmployeeInviteModel.fromJson(u))
          .toList();
    }
    return {"employees": employees, "invites": invites};
  }

  void saveToClipboard({bool invites = true}) {
    if (_invites.isEmpty) {
      return;
    }
    String inviteData = _invites
        .map((e) => "${e.userEmail},${e.verificationCode}")
        .toList()
        .join('\n');
    Clipboard.setData(ClipboardData(text: inviteData));
    CustomWidgets.buildSnackBar(
        context, "Copied to clipboard", SLSnackBarType.neutral);
  }

  @override
  Widget build(BuildContext context) {
    //String? searchText;

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
                        'User',
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
                        'Job Title',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Roles',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ], rows: <DataRow>[
                    ..._employees.map((e) => DataRow(cells: <DataCell>[
                          DataCell(
                              Row(children: [
                                ClickableAvatar(
                                  avatarText: e.initials,
                                  avatarImage: e.profileImage(),
                                  radius: 30,
                                ),
                                const ListSpacer(),
                                Text(e.name)
                              ]),
                              onTap: () => {_goToAccount(e.id)}),
                          DataCell(Text(e.inviteEmail)),
                          DataCell(Text(e.jobTitle)),
                          DataCell(Text(e.roles.join(", ")))
                        ]))
                  ]))));
    }

    Widget _buildInvitesTable() {
      return Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Invite Email',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Job Title',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Invite sent',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Invite Code',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ], rows: <DataRow>[
                    ..._invites.map((e) => DataRow(cells: <DataCell>[
                          DataCell(Text(e.userEmail)),
                          DataCell(Text(e.jobTitle ?? "")),
                          DataCell(Text(timeago.format(e.createdAt!))),
                          DataCell(Text(e.verificationCode ?? ""))
                        ]))
                  ]))));
    }

    Widget _buildButtonRow() {
      Widget row = Row(children: [
        const Spacer(),
        OutlinedButton(
            style: OutlinedButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: _toggleShowingInvites,
            child: Text("Show " + (_showingInvites ? "Team" : "Invites"))),
        const ListSpacer(),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                onPrimary: Theme.of(context).colorScheme.onError),
            onPressed: _showInviteOption,
            child: const Text("Create Invite Codes"))
      ]);

      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _showingInvites
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  row,
                  Row(children: [
                    const Spacer(),
                    OutlinedButton.icon(
                        icon: const Icon(Icons.download_outlined),
                        onPressed: saveToClipboard,
                        label: const Text("Copy"))
                  ])
                ])
              : row);
    }

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return FutureBuilder(
          future: fetchTeamAndInvites(client),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _employees = snapshot.data['employees'];
              _invites = snapshot.data['invites'];
            }
            return Container(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildButtonRow(),
                    Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          (_showingInvites
                                      ? _invites.length
                                      : _employees.length)
                                  .toString() +
                              " results",
                          style: Theme.of(context).textTheme.caption,
                        )),
                    Expanded(
                        child: _showingInvites
                            ? _buildInvitesTable()
                            : _buildUserTable()),
                  ],
                ));
          });
    });
  }
}
