import 'package:community_app/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommentModel extends ChangeNotifier {
  String id = "";
  String body = "";

  UserModel _creator = UserModel();

  UserModel get creator => _creator;

  set creator(UserModel creator) {
    _creator = creator;
    notifyListeners();
  }

  CommentModel();

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    body = json['body'];
    creator = UserModel.fromJson(json['createdBy']);
  }
  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
