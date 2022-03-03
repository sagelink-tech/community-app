import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/invite_model.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/ui/components/moderation_options_sheet.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';
import 'package:sagelink_communities/ui/views/users/invite_page.dart';
import 'package:timeago/timeago.dart' as timeago;

String getMembersQuery = """
query Users(\$where: UserWhere, \$options: UserOptions, \$inviteWhere: InviteWhere, \$inviteOptions: InviteOptions) {
  users(where: \$where, options: \$options) {
    id
    description
    name
    accountPictureUrl
    createdAt
    flaggedInBrands {
      id
    }
    bannedFromBrands {
      id
    }
    memberOfBrandsConnection {
      edges {
        tier
        customerId
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
    memberTier
    isAdmin
    createdAt
    forBrand {
      id
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
  List<MemberInviteModel> _invites = [];

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
              child: InvitePage(inviteType: InviteType.members));
        });
  }

  void _goToAccount(String userId) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: userId)));
  }

  Future<dynamic> fetchMembersAndInvites(GraphQLClient client) async {
    Map<String, dynamic> variables = {
      "where": {
        "memberOfBrands": {"id": loggedInUser.adminBrandId}
      },
      "options": {
        "sort": [
          {"createdAt": "ASC", "name": "ASC"}
        ]
      },
      "inviteWhere": {
        "forBrand": {"id": loggedInUser.adminBrandId},
        "isAdmin": false
      },
      "inviteOptions": {
        "sort": [
          {"createdAt": "ASC", "userEmail": "ASC"}
        ]
      }
    };

    List<MemberModel> members = [];
    List<MemberInviteModel> invites = [];
    QueryResult result = await client.query(
        QueryOptions(document: gql(getMembersQuery), variables: variables));

    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      members = (result.data!['users'] as List)
          .map((u) => MemberModel.fromJson(u, loggedInUser.adminBrandId!))
          .toList();
    }
    if (result.data != null && (result.data!['invites'] as List).isNotEmpty) {
      invites = (result.data!['invites'] as List)
          .map((u) => MemberInviteModel.fromJson(u))
          .toList();
    }
    return {"members": members, "invites": invites};
  }

  @override
  Widget build(BuildContext context) {
    //String? searchText;

    Widget _buildStatusButton(MemberModel member) {
      Icon icon = Icon(member.isBanned
          ? Icons.block_outlined
          : member.isFlagged
              ? Icons.flag_outlined
              : Icons.check_circle_outline_outlined);
      return IconButton(
          icon: icon,
          onPressed: () => {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return ModerationOptionsSheet(
                        ModerationOptionSheetType.user,
                        brandId: loggedInUser.adminBrandId,
                        user: member,
                        onComplete: () => {setState(() => {})},
                      );
                    })
              });
    }

    Widget _buildUserTable() {
      return Container(
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
                        'Invite Email',
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
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ], rows: <DataRow>[
                    ..._members.map((e) => DataRow(cells: <DataCell>[
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
                          DataCell(Text(timeago.format(e.memberSince))),
                          DataCell(Text(e.tier)),
                          DataCell(_buildStatusButton(e))
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
                        'Email',
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
                        'Tier',
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
                          DataCell(Text(timeago.format(e.createdAt!))),
                          DataCell(Text(e.memberTier!)),
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
            child: Text("Show " + (_showingInvites ? "Members" : "Invites"))),
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
                        onPressed: () => {},
                        label: const Text("Copy"))
                  ])
                ])
              : row);
    }

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return FutureBuilder(
          future: fetchMembersAndInvites(client),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return const ErrorView();
            } else if (!snapshot.hasData) {
              return const Loading();
            }
            if (snapshot.hasData) {
              _members = snapshot.data['members'];
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
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          (_showingInvites ? _invites.length : _members.length)
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
