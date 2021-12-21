import 'package:sagelink_communities/models/brand_model.dart';
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  String id = "123";
  String username = "username";
  String name = "full name";
  String email = "email@email.com";
  String accountPictureUrl = "";

  List<String> _userPosts = [];

  List<String> get userPosts => _userPosts;

  set userPosts(List<String> userPosts) {
    _userPosts = userPosts;
    notifyListeners();
  }

  List<BrandModel> _brands = [];
  List<BrandModel> get brands => _brands;

  set brands(List<BrandModel> brands) {
    _brands = brands;
    notifyListeners();
  }

  UserModel();

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    name = json['name'];
    email = json.containsKey('email') ? json['email'] : "";
    accountPictureUrl =
        json.containsKey('accountPictureUrl') ? json['accountPictureUrl'] : "";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'accountPictureUrl': accountPictureUrl
      };
}
