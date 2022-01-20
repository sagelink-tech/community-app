import 'package:sagelink_communities/models/brand_model.dart';
import 'package:sagelink_communities/models/user_model.dart';
import 'package:sagelink_communities/models/comment_model.dart';
import 'package:flutter/material.dart';

enum PostType { text, link, images } //, poll, survey }

extension PostTypeManager on PostType {
  String toShortString() {
    return toString().split('.').last;
  }

  static PostType fromShortString(String type) {
    for (var v in PostType.values) {
      if (type == v.toShortString()) {
        return v;
      }
    }
    return PostType.text;
  }

  Icon iconForPostType() {
    switch (this) {
      case PostType.text:
        return const Icon(Icons.forum_outlined);
      case PostType.link:
        return const Icon(Icons.add_link_outlined);
      case PostType.images:
        return const Icon(Icons.camera_alt_outlined);
      // case PostType.poll:
      //   return const Icon(Icons.poll_outlined);
      // case PostType.survey:
      //   return const Icon(Icons.dynamic_form_outlined);
    }
  }
}

class PostModel extends ChangeNotifier {
  String id = "";
  String title = "";
  String? body;
  String? linkUrl;
  List<String>? images;

  DateTime createdAt = DateTime(2020, 1, 1, 0, 0, 1);
  int commentCount = 0;
  PostType type = PostType.text;

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
    body = json.containsKey('body') ? json['body'] : null;
    linkUrl = json.containsKey('linkUrl') ? json['linkUrl'] : null;
    if (json.containsKey('images') && json['images'] != null) {
      images = [];
      for (var im in json["images"]) {
        images!.add(im as String);
      }
    }

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
    var pType =
        json.containsKey("type") ? json['type'] : PostType.text.toShortString();
    type = PostTypeManager.fromShortString(pType);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseData = {
      'id': id,
      'title': title,
      'type': type.toShortString(),
    };
    switch (type) {
      case (PostType.text):
        baseData['body'] = body;
        break;
      case (PostType.images):
        baseData['images'] = images;
        break;
      case (PostType.link):
        baseData['linkUrl'] = linkUrl;
        break;
    }
    return baseData;
  }
}
