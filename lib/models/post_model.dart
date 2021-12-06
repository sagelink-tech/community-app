import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:community_app/models/comment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PostType { undefined, text, image, url, poll, survey, product }

class PostModel extends ChangeNotifier {
  String id = "";
  String title = "";
  String body = "";
  DateTime createdAt = DateTime(2020, 1, 1, 0, 0, 1);
  int commentCount = 0;
  PostType type = PostType.undefined;

  BrandModel _brand = BrandModel();

  BrandModel get brand => _brand;

  set brand(BrandModel brand) {
    _brand = brand;
    notifyListeners();
  }

  UserModel _creator = UserModel();

  UserModel get creator => _creator;

  set creator(UserModel creator) {
    _creator = creator;
    notifyListeners();
  }

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;
  set comments(List<CommentModel> comments) {
    _comments = comments;
    notifyListeners();
  }

  PostModel();

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
    commentCount = json['commentsAggregate']['count'];
    if (json.containsKey('createdAt')) {
      createdAt =
          DateTime.tryParse(json["createdAt"]) ?? DateTime(2020, 1, 1, 0, 0, 1);
    }
    if (json.containsKey('createdBy')) {
      creator = UserModel.fromJson(json['createdBy']);
    }
    if (json.containsKey('inBrandCommunity')) {
      brand = BrandModel.fromJson(json['inBrandCommunity']);
    }

    List<CommentModel> commentList = [];
    if (json.containsKey('comments')) {
      for (var c in json['comments']) {
        commentList.add(CommentModel.fromJson(c));
      }
    }
    comments = commentList;

    //Need to serialize/deserialize properly
    type = PostType.text;
  }
  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
