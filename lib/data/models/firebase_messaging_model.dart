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

  Future<void> requestPermissionAndUpdateToken() async {
    NotificationSettings settings =
        await messagingInstance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await messagingInstance.requestPermission();
    }
    if (settings.authorizationStatus != AuthorizationStatus.denied) {
      String? token = await messagingInstance.getToken();
      if (token != null) {
        await userService.addNewDeviceToken(token);
        await syncSubscriptions();
      }
    }
  }

  Future<void> syncSubscriptions() async {
    var settingsResult = await userService.fetchNotificationSettings();

    for (var settingsForBrand in settingsResult) {
      if (settingsForBrand.keys.first == 'Sagelink App') {
        // sl settings
        for (var element in settingsForBrand.values.first) {
          if (element.status == true) {
            messagingInstance.subscribeToTopic(
                element.topic == MessagingTopics.slAnnouncments
                    ? slAnnouncementsTopic
                    : slDigestTopic);
          }
        }
      } else {
        // all other brand settings
        for (var element in settingsForBrand.values.first) {
          if (element.status == true) {
            switch (element.topic) {
              case MessagingTopics.brandAnnouncments:
                messagingInstance.subscribeToTopic(
                    element.brand!.id + brandAnnouncementsTopic);
                break;
              case MessagingTopics.brandDigest:
                messagingInstance
                    .subscribeToTopic(element.brand!.id + brandDigestTopic);
                break;
              case MessagingTopics.brandNewPosts:
                messagingInstance
                    .subscribeToTopic(element.brand!.id + brandNewPostsTopic);
                break;
              case MessagingTopics.brandPerks:
                messagingInstance
                    .subscribeToTopic(element.brand!.id + brandPerksTopic);
                break;
              default:
                break;
            }
          }
        }
      }
    }
  }

  Future<void> subscribeToTopicsForBrand({String? brandId}) async {
    List<String> topicStrings = (brandId != null)
        ? [
            brandId + brandAnnouncementsTopic,
            brandId + brandDigestTopic,
            brandId + brandNewPostsTopic,
            brandId + brandPerksTopic,
          ]
        : [slAnnouncementsTopic, slDigestTopic];
    List<Future> futures =
        topicStrings.map((e) => messagingInstance.subscribeToTopic(e)).toList();
    Future.wait(futures);
  }

  Future<void> subscribeToSLTopics() async {
    List<String> topicStrings = [slAnnouncementsTopic, slDigestTopic];
    List<Future> futures =
        topicStrings.map((e) => messagingInstance.subscribeToTopic(e)).toList();
    Future.wait(futures);
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
