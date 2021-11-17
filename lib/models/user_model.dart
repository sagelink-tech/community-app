import 'package:community_app/models/brand_model.dart';
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  String id = "";
  String username = "";
  String name = "";
  String email = "";
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
    email = json['email'];
    //accountPictureUrl = json['accountPictureUrl'];
  }

  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
