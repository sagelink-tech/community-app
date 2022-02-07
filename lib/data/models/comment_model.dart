import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommentModel extends ChangeNotifier {
  String id = "";
  String body = "";
  DateTime createdAt = DateTime(2020, 1, 1, 0, 0, 1);
  int replyCount = 0;
  bool isFlaggedByUser = false;

  UserModel _creator = UserModel();

  UserModel get creator => _creator;

  set creator(UserModel creator) {
    _creator = creator;
    notifyListeners();
  }

  List<CommentModel> _replies = [];
  List<CommentModel> get replies => _replies;
  set replies(List<CommentModel> replies) {
    _replies = replies;
    notifyListeners();
  }

  CommentModel();

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    body = json['body'];
    creator = UserModel.fromJson(json['createdBy']);
    if (json.containsKey('createdAt')) {
      createdAt =
          DateTime.tryParse(json["createdAt"]) ?? DateTime(2020, 1, 1, 0, 0, 1);
    }
    replyCount = json.containsKey('repliesAggregate')
        ? replyCount = json['repliesAggregate']['count']
        : 0;
    if (json.containsKey('isFlaggedByUser')) {
      isFlaggedByUser = json['isFlaggedByUser'];
    }
    List<CommentModel> replyList = [];
    if (json.containsKey('replies')) {
      for (var c in json['replies']) {
        replyList.add(CommentModel.fromJson(c));
      }
    }
    replies = replyList;
  }
  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
