import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/data/models/firebase_messaging_model.dart';
import 'package:sagelink_communities/data/models/invite_model.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/models/user_model.dart';

// ignore: constant_identifier_names
const String UPDATE_USER_MUTATION = '''
mutation Mutation(\$update: UserUpdateInput, \$where: UserWhere, \$connect: UserConnectInput, \$disconnect: UserDisconnectInput) {
  updateUsers(update: \$update, where: \$where, connect: \$connect, disconnect: \$disconnect) {
    users {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String FETCH_USER_DISPLAY_DATA = '''
query Query(\$where: UserWhere) {
  users(where: \$where) {
    id
    firebaseId
    name
    accountPictureUrl
  }
}
''';

// ignore: constant_identifier_names
const String FETCH_MESSAGEBLE_USERS = '''
query Users(\$where: BrandWhere, \$sort: [BrandEmployeesConnectionSort!], \$memberOfBrandsConnectionSort2: [BrandMembersConnectionSort!]) {
  brands(where: \$where) {
    id
    name
    mainColor
    logoUrl
    employeesConnection(sort: \$sort) {
      totalCount
      edges {
        node {
          id
          firebaseId
          name
          accountPictureUrl
          queryUserHasBlocked
          queryUserIsBlocked
        }
        roles
        founder
        owner
        jobTitle
      }
    }
    membersConnection(sort: \$memberOfBrandsConnectionSort2) {
      totalCount
      edges {
        node {
          id
          firebaseId
          name
          accountPictureUrl
          queryUserHasBlocked
          queryUserIsBlocked
        }
      }
    }
  }
}
''';

// ignore: constant_identifier_names
const String FETCH_INVITE_CODES_QUERY = '''
query Query{
  invites {
    verificationCode
  }
}
''';

// ignore: constant_identifier_names
const String CREATE_INVITES_MUTATION = '''
mutation Mutation(\$input: [InviteCreateInput!]!) {
  createInvites(input: \$input) {
    invites {
      id
    }
  }
}
''';

// ignore: constant_identifier_names
const String GENERATE_INVITE_CODES_MUTATION = '''
mutation GenerateCodesForInvites(\$inviteIds: [String!]!) {
  generateCodesForInvites(inviteIds: \$inviteIds) {
    id
  }
}
''';

//ignore: constant_identifier_names
const String ACCEPT_INVITE_MUTATION = '''
mutation Mutation(\$verificationCode: String!) {
  acceptInvite(verificationCode: \$verificationCode)
}
''';

//ignore: constant_identifier_names
const String FETCH_NOTIFICATION_SETTINGS = '''
query Query(\$where: UserWhere, \$options: UserOptions, \$sort: [UserEmployeeOfBrandsConnectionSort!], \$memberOfBrandsConnectionSort2: [UserMemberOfBrandsConnectionSort!]) {
  users(where: \$where, options: \$options) {
    subscribedToSLDigest
    subscribedToSLAnnouncements
    notifyOnMessages
    memberOfBrandsConnection(sort: \$memberOfBrandsConnectionSort2) {
      edges {
        subscribedToDigest
        subscribedToPerks
        subscribedToAnnouncements
        subscribedToNewPosts
        notifyOnReplies
        node {
          id
          name
          logoUrl
          mainColor
        }
      }
    }
    employeeOfBrandsConnection(sort: \$sort) {
      edges {
        subscribedToDigest
        subscribedToPerks
        subscribedToAnnouncements
        subscribedToNewPosts
        notifyOnReplies
        node {
          id
          name
          logoUrl
          mainColor
        }
      }
    }
  }
}
''';

class UserService {
  final GraphQLClient client;
  final LoggedInUser authUser;

  const UserService({required this.client, required this.authUser});

  /////////////////////////////////////////////////////////////
  /// Finding users
  /////////////////////////////////////////////////////////////

  Future<List<UserModel>> fetchMessagebleUers() async {
    final brands = authUser.getUser().brands;
    QueryResult result = await client
        .query(QueryOptions(document: gql(FETCH_MESSAGEBLE_USERS), variables: {
      "where": {"id_IN": brands.map((e) => e.id).toList()}
    }));
    if (result.hasException ||
        result.data == null ||
        (result.data!['brands'] as List).isEmpty) {
      return [];
    }

    List<UserModel> _users = [];
    for (var b in result.data!['brands']) {
      BrandModel _brand = BrandModel.fromJson(b);
      _users.addAll([..._brand.employees, ..._brand.members].where((element) =>
          element.queryUserHasBlocked == false &&
          element.queryUserIsBlocked == false &&
          element.id != authUser.getUser().id));
    }
    return [
      ...{..._users}
    ];
  }

  Future<List<UserModel>?> fetchUserDisplayData(
      {List<String>? userIds, List<String>? firebaseIds}) async {
    Map<String, dynamic> whereClause = {};
    if (userIds == null && firebaseIds == null) {
      return null;
    } else {
      whereClause = (userIds != null)
          ? {"id_IN": userIds}
          : {"firebaseId_IN": firebaseIds};
    }
    QueryResult result = await client.query(QueryOptions(
        document: gql(FETCH_USER_DISPLAY_DATA),
        variables: {"where": whereClause}));

    if (result.hasException ||
        result.data == null ||
        (result.data!['users'] as List).isEmpty) {
      return null;
    } else {
      return (result.data!['users'] as List)
          .map((el) => UserModel.fromJson(el))
          .toList();
    }
  }

  /////////////////////////////////////////////////////////////
  /// Manage members and team
  /////////////////////////////////////////////////////////////

  // Generate invites to a community
  Future<bool> inviteUsersToTeam(List<EmployeeInviteModel> invites,
      {OnMutationCompleted? onComplete}) async {
    // First generate the invite entitites
    Map<String, dynamic> variables = {
      "input": invites
          .map((e) => {
                //"verificationCode": e.verificationCode,
                "userEmail": e.userEmail,
                "isAdmin": e.isAdmin,
                "founder": e.founder,
                "owner": e.owner,
                "jobTitle": e.jobTitle,
                "forBrand": {
                  "connect": {
                    "where": {
                      "node": {"id": e.brandId}
                    }
                  }
                }
              })
          .toList()
    };
    QueryResult response = await client.mutate(MutationOptions(
        document: gql(CREATE_INVITES_MUTATION), variables: variables));

    // If success, generate codes for the new invites
    if (response.hasException || response.data == null) {
      return false;
    }

    Map<String, dynamic> input = {
      "inviteIds": response.data!['createInvites']['invites']
          .map((inv) => inv['id'])
          .toList()
    };

    response = await client.mutate(MutationOptions(
        document: gql(GENERATE_INVITE_CODES_MUTATION), variables: input));

    // Return
    if (response.hasException || response.data == null) {
      return false;
    }

    if (onComplete != null) {
      onComplete(response.data);
    }
    return true;
  }

  // Generate invites to a community
  Future<bool> inviteUsersToCommunity(List<MemberInviteModel> invites,
      {OnMutationCompleted? onComplete}) async {
    // First generate the invite entitites
    Map<String, dynamic> variables = {
      "input": invites
          .map((e) => {
                //"verificationCode": e.verificationCode,
                "userEmail": e.userEmail,
                "isAdmin": e.isAdmin,
                "memberTier": e.memberTier,
                "customerId": e.customerId,
                "forBrand": {
                  "connect": {
                    "where": {
                      "node": {"id": e.brandId}
                    }
                  }
                }
              })
          .toList()
    };
    QueryResult response = await client.mutate(MutationOptions(
        document: gql(CREATE_INVITES_MUTATION), variables: variables));

    // If success, generate codes for the new invites
    if (response.hasException || response.data == null) {
      return false;
    }

    Map<String, dynamic> input = {
      "inviteIds": response.data!['createInvites']['invites']
          .map((inv) => inv['id'])
          .toList()
    };

    response = await client.mutate(MutationOptions(
        document: gql(GENERATE_INVITE_CODES_MUTATION), variables: input));

    // Return
    if (response.hasException) {
      return false;
    }

    if (onComplete != null) {
      onComplete(response.data);
    }
    return true;
  }

  // Add a user to a community
  Future<bool> acceptInvitationWithCode(String inviteCode,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {"verificationCode": inviteCode};

    QueryResult result = await client.mutate(MutationOptions(
        document: gql(ACCEPT_INVITE_MUTATION), variables: variables));

    if (result.hasException || result.data == null) {
      return false;
    }
    return result.data!['acceptInvite'];
  }

  // Remove a user from a community
  // This actually bans the user from the community
  Future<bool> banUserFromCommunity(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only ban users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "connect": {
        "bannedFromBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Remove a user from a community
  // This actually bans the user from the community
  Future<bool> unbanUserFromCommunity(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only ban users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "disconnect": {
        "bannedFromBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Change admin status
  // TODO
  Future<bool> changeAdminStatus(
      UserModel user, String brandId, Map<String, dynamic>? adminDetails,
      {OnMutationCompleted? onComplete}) async {
    if (adminDetails == null) {
      // disconnect as admin
    } else {
      // connect as admin
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Blocking and flagging users
  /////////////////////////////////////////////////////////////

  // Block a user
  Future<bool> blockUser(UserModel user,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "where": {"id": authUser.getUser().id},
      "connect": {
        "blockedUsers": {
          "where": {
            "node": {"id": user.id},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == authUser.getUser().id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Unblock a user
  Future<bool> unblockUser(UserModel user,
      {OnMutationCompleted? onComplete}) async {
    Map<String, dynamic> variables = {
      "where": {"id": authUser.getUser().id},
      "disconnect": {
        "blockedUsers": {
          "where": {
            "node": {"id": user.id},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == authUser.getUser().id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Unflag a user
  Future<bool> unflagUser(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only flag users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "disconnect": {
        "flaggedInBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  // Flag a user
  Future<bool> flagUser(UserModel user, String brandId,
      {OnMutationCompleted? onComplete}) async {
    if (authUser.adminBrandId != brandId) {
      // can only flag users in your own community
      return false;
    }

    Map<String, dynamic> variables = {
      "where": {"id": user.id},
      "connect": {
        "flaggedInBrands": {
          "where": {
            "node": {"id": authUser.adminBrandId},
          }
        }
      }
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        result.data!['updateUsers']['users'][0]['id'] == user.id);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// Update user data
  /////////////////////////////////////////////////////////////

  // Add new device token
  Future<bool> addNewDeviceToken(String deviceToken) async {
    List<String> deviceTokens = [...authUser.deviceTokens];
    if (!deviceTokens.contains(deviceToken)) {
      deviceTokens.add(deviceToken);

      return await updateUserWithID(authUser.getUser().id, {
        "deviceTokens": deviceToken,
        "lastDeviceTokenUpdate": DateTime.now().toIso8601String()
      });
    } else {
      return true;
    }
  }

  // Update subscription status
  Future<bool> updateTopicSubscriptionStatus(
      MessagingTopics topic, String? brandId, bool status) async {
    Map<String, dynamic> userUpdateData = {};
    var relUpdateData = {};

    bool isEmployee = false;
    bool isMember = false;

    if (brandId != null &&
        ![MessagingTopics.slAnnouncments, MessagingTopics.slDigest]
            .contains(topic)) {
      if (authUser.adminBrandId == brandId) {
        isEmployee = true;
      } else {
        isMember = true;
      }
    }

    switch (topic) {
      case MessagingTopics.slAnnouncments:
        userUpdateData["subscribedToSLAnnouncements"] = status;
        break;
      case MessagingTopics.slDigest:
        userUpdateData["subscribedToSLDigest"] = status;
        break;
      case MessagingTopics.newMessages:
        userUpdateData["notifyOnMessages"] = status;
        break;
      case MessagingTopics.brandAnnouncments:
        relUpdateData["subscribedToAnnouncements"] = status;
        break;
      case MessagingTopics.brandDigest:
        relUpdateData["subscribedToDigest"] = status;
        break;
      case MessagingTopics.brandNewPosts:
        relUpdateData["subscribedToNewPosts"] = status;
        break;
      case MessagingTopics.brandPerks:
        relUpdateData["subscribedToPerks"] = status;
        break;
      case MessagingTopics.brandContentReplies:
        relUpdateData["notifyOnReplies"] = status;
        break;
    }

    if (isEmployee || isMember) {
      var data = [
        {
          "where": {
            "node": {"id": brandId}
          },
          "update": {"edge": relUpdateData}
        }
      ];
      if (isMember) {
        userUpdateData['memberOfBrands'] = data;
      }
      if (isEmployee) {
        userUpdateData['employeeOfBrands'] = data;
      }
    }

    return await updateUserWithID(authUser.getUser().id, userUpdateData);
  }

  // Update user with update dictionary
  Future<bool> updateUserWithID(String userId, Map<String, dynamic> updateData,
      {OnMutationCompleted? onComplete, bool requireAuth = true}) async {
    if (requireAuth) {
      if (userId != authUser.getUser().id) {
        return false;
      }
    }

    Map<String, dynamic> variables = {
      "update": updateData,
      "where": {"id": userId}
    };

    MutationOptions options = MutationOptions(
        document: gql(UPDATE_USER_MUTATION), variables: variables);
    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception);
      return false;
    }

    bool success = (result.data != null &&
        (result.data!['updateUsers']['users'] as List).isNotEmpty &&
        result.data!['updateUsers']['users'][0]['id'] == userId);

    if (success && onComplete != null) {
      onComplete(result.data);
    }
    return true;
  }

  /////////////////////////////////////////////////////////////
  /// User helpers
  /////////////////////////////////////////////////////////////

  Future<List<Map<String, List<NotificationSetting>>>>
      fetchNotificationSettings() async {
    Map<String, dynamic> variables = {
      "where": {"id": authUser.getUser().id},
      "options": {"limit": 1},
      "sort": [
        {
          "node": {"name": "DESC"}
        }
      ],
      "memberOfBrandsConnectionSort2": [
        {
          "node": {"name": "DESC"}
        }
      ]
    };

    QueryResult result = await client.query(QueryOptions(
        document: gql(FETCH_NOTIFICATION_SETTINGS), variables: variables));
    if (result.hasException ||
        result.data == null ||
        (result.data!['users'] as List).isEmpty) {
      return [];
    } else {
      // parse to something usable
      Map<String, dynamic> _userData = result.data!['users'][0];

      List<Map<String, List<NotificationSetting>>> settings = [];
      settings.add({
        'Sagelink App': [
          NotificationSetting(
              title: "Announcements",
              topic: MessagingTopics.slAnnouncments,
              status: _userData['subscribedToSLAnnouncements'] ?? false),
          NotificationSetting(
              title: "Digest",
              topic: MessagingTopics.slDigest,
              status: _userData['subscribedToSLDigest'] ?? false),
          NotificationSetting(
              title: "New Direct Messages",
              topic: MessagingTopics.newMessages,
              status: _userData['notifyOnMessages'] ?? false)
        ]
      });

      for (var brandData in _userData['employeeOfBrandsConnection']['edges']) {
        BrandModel brand = BrandModel.fromJson(brandData['node']);

        settings.add({
          brand.name: [
            NotificationSetting(
                title: "Announcements",
                brand: brand,
                topic: MessagingTopics.brandAnnouncments,
                status: brandData['subscribedToAnnouncements'] ?? false),
            NotificationSetting(
                title: "Digest",
                brand: brand,
                topic: MessagingTopics.brandDigest,
                status: brandData['subscribedToDigest'] ?? false),
            NotificationSetting(
                title: "Perk Updates",
                brand: brand,
                topic: MessagingTopics.brandPerks,
                status: brandData['subscribedToPerks'] ?? false),
            NotificationSetting(
                title: "New Posts",
                brand: brand,
                topic: MessagingTopics.brandNewPosts,
                status: brandData['subscribedToNewPosts'] ?? false),
            NotificationSetting(
                title: "Replies to my content",
                brand: brand,
                topic: MessagingTopics.brandContentReplies,
                status: brandData['notifyOnReplies'] ?? false)
          ]
        });
      }

      for (var brandData in _userData['memberOfBrandsConnection']['edges']) {
        BrandModel brand = BrandModel.fromJson(brandData['node']);
        settings.add({
          brand.name: [
            NotificationSetting(
                title: "Announcements",
                brand: brand,
                topic: MessagingTopics.brandAnnouncments,
                status: brandData['subscribedToAnnouncements'] ?? false),
            NotificationSetting(
                title: "Digest",
                brand: brand,
                topic: MessagingTopics.brandDigest,
                status: brandData['subscribedToDigest'] ?? false),
            NotificationSetting(
                title: "Perk Updates",
                brand: brand,
                topic: MessagingTopics.brandPerks,
                status: brandData['subscribedToPerks'] ?? false),
            NotificationSetting(
                title: "New Posts",
                brand: brand,
                topic: MessagingTopics.brandNewPosts,
                status: brandData['subscribedToNewPosts'] ?? false),
            NotificationSetting(
                title: "Replies to my content",
                brand: brand,
                topic: MessagingTopics.brandContentReplies,
                status: brandData['notifyOnReplies'] ?? false)
          ]
        });
      }
      return settings;
    }
  }
}

class NotificationSetting {
  String title;
  MessagingTopics topic;
  bool status;
  BrandModel? brand;
  NotificationSetting({
    required this.title,
    required this.topic,
    required this.status,
    this.brand,
  });
}
