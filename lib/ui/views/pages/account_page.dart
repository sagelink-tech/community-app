import 'package:sagelink_communities/ui/components/brand_chip.dart';
import 'package:sagelink_communities/ui/components/causes_chips.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/error_view.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/loading.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getUserQuery = """
query UsersQuery(\$where: UserWhere, \$options: UserOptions) {
  users(where: \$where, options: \$options) {
    name
    id
    description
    accountPictureUrl
    memberOfBrands {
      id
      name
      logoUrl
      mainColor
    }
    causes {
      title
      id
    }
    employeeOfBrands {
      id
      name
      logoUrl
      mainColor  
    }
  }
}
""";

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  static const routeName = '/users';

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage>
    with SingleTickerProviderStateMixin {
  UserModel _user = UserModel();

  bool _isEditing = false;

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<UserModel?> _getUser(GraphQLClient client) async {
    //client.resetStore();
    Map<String, dynamic> variables = {
      "where": {"id": widget.userId},
      "options": {"limit": 1}
    };

    QueryResult result = await client
        .query(QueryOptions(document: gql(getUserQuery), variables: variables));
    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      return UserModel.fromJson(result.data?['users'][0]);
    }
    return null;
  }

  _buildHeader(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClickableAvatar(
              avatarText: _user.name[0],
              avatarURL: _user.accountPictureUrl,
              radius: 60),
          const ListSpacer(height: 20),
          Text(_user.name,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.start),
          const ListSpacer(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                // onPrimary: Theme.of(context).colorScheme.onSecondary,
                minimumSize: const Size.fromHeight(48)),
            onPressed: () => {},
            child: Text('Message',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onError)),
          ),
          const ListSpacer(height: 20),
        ]);
  }

  _buildBody(BuildContext context) {
    List<Widget> _causeComponents = _user.causes.isNotEmpty
        ? [
            Text(
              "Causes",
              style: Theme.of(context).textTheme.headline4,
            ),
            CausesChips(causes: _user.causes),
          ]
        : [];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: Theme.of(context).textTheme.headline4,
        ),
        const ListSpacer(),
        Text(
          _user.description,
          style: Theme.of(context).textTheme.caption,
        ),
        const ListSpacer(),
        Text(
          "Member at",
          style: Theme.of(context).textTheme.headline4,
        ),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _user.brands
              .map((b) => BrandChip(brand: b, onTap: (brand) => {}))
              .toList(),
        ),
        const ListSpacer(),
        ..._causeComponents,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = ref.watch(loggedInUserProvider);

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return FutureBuilder(
          future: _getUser(client),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              _user = snapshot.data;
            } else if (snapshot.hasError) {
              //TO DO: DEBUG THIS ERROR
            }
            return Scaffold(
                appBar: AppBar(
                    title: null,
                    actions: loggedInUser.getUser().id == _user.id
                        ? [
                            IconButton(
                              onPressed: _toggleEditing,
                              icon: Icon(_isEditing ? Icons.done : Icons.edit),
                            )
                          ]
                        : null,
                    backgroundColor: Theme.of(context).backgroundColor,
                    elevation: 0),
                body: (snapshot.hasData
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [_buildHeader(context), _buildBody(context)],
                      )
                    : snapshot.hasError
                        ? const ErrorView()
                        : const Loading()));
          });
    });
  }
}
