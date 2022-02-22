import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sagelink_communities/data/services/user_service.dart';

const slAnnouncementsTopic = "sagelink_announcments";
const brandAnnouncementsTopic = "_announcements";
const brandPerksTopic = "_perks";
const brandDigestTopic = "_digest";
const brandNewPostsTopic = "_new_posts";
const slDigestTopic = "sagelink_digest";

enum MessagingTopics {
  slAnnouncments,
  brandAnnouncments,
  brandPerks,
  brandDigest,
  brandNewPosts,
  slDigest,
  brandContentReplies,
  newMessages,
}

class Messaging {
  // For Authentication related functions you need an instance of FirebaseAuth
  final FirebaseMessaging messagingInstance = FirebaseMessaging.instance;
  final UserService userService;
  final DateTime? lastTokenUpdate;

  Messaging({required this.userService, required this.lastTokenUpdate});

  Future<void> addNewToken() async {
    String? token = await messagingInstance.getToken();
    if (token != null) {
      userService.addNewDeviceToken(token);
    }
  }

  Future<void> requestPermissionAndUpdateToken() async {
    print("REQUESTING TOKEN");
    NotificationSettings settings =
        await messagingInstance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await messagingInstance.requestPermission();
      print('User granted permission: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus != AuthorizationStatus.denied) {
      if (lastTokenUpdate == null ||
          lastTokenUpdate!
              .isBefore(DateTime.now().subtract(const Duration(days: 10)))) {
        await addNewToken();
      }
    }
  }

  Future<bool> setTopicSubscriptionStatus(
      bool subscribe, MessagingTopics topicType,
      {String? forBrandId}) async {
    String topicString;
    switch (topicType) {
      case MessagingTopics.slAnnouncments:
        topicString = slAnnouncementsTopic;
        break;
      case MessagingTopics.slDigest:
        topicString = slDigestTopic;
        break;
      case MessagingTopics.brandAnnouncments:
        if (forBrandId == null || forBrandId.isEmpty) {
          return false;
        }
        topicString = forBrandId + brandAnnouncementsTopic;
        break;
      case MessagingTopics.brandPerks:
        if (forBrandId == null || forBrandId.isEmpty) {
          return false;
        }
        topicString = forBrandId + brandPerksTopic;
        break;
      case MessagingTopics.brandDigest:
        if (forBrandId == null || forBrandId.isEmpty) {
          return false;
        }
        topicString = forBrandId + brandDigestTopic;
        break;
      case MessagingTopics.brandNewPosts:
        if (forBrandId == null || forBrandId.isEmpty) {
          return false;
        }
        topicString = forBrandId + brandNewPostsTopic;
        break;
      default:
        topicString = "";
        break;
    }

    if (topicString.isNotEmpty) {
      subscribe
          ? (await messagingInstance.subscribeToTopic(topicString))
          : (await messagingInstance.unsubscribeFromTopic(topicString));
    }
    return await userService.updateTopicSubscriptionStatus(
        topicType, forBrandId, subscribe);
  }
}
