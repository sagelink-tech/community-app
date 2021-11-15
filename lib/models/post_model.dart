import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PostType { undefined, text, image, url, poll, survey, product }

class PostModel extends ChangeNotifier {
  String id = "";
  String title = "";
  String body = "";
  String embeddedUrl = "";
  String description = "";
  String imageUrl = "";
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

  PostModel();

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    body = json['body'];
    embeddedUrl = json['embeddedUrl'];
    imageUrl = json['imageUrl'];
    //Need to serialize/deserialize properly
    type = PostType.text;
  }
  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
