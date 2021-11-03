import 'package:community_app/models/user_model.dart';
import 'package:flutter/foundation.dart';

class BrandModel extends ChangeNotifier {
  String name = "";
  String description = "";
  String logoUrl = "";
  String website = "";
  String relationship = "";

  List<UserModel> _owners = [];

  List<UserModel> get owners => _owners;

  set owners(List<UserModel> owners) {
    _owners = owners;
    notifyListeners();
  }

  List<UserModel> _followers = [];

  List<UserModel> get followers => _followers;

  set followers(List<UserModel> followers) {
    _followers = followers;
    notifyListeners();
  }

  BrandModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    logoUrl = json['logoUrl'];
    website = json['website'];
    relationship = json['relationship'];
  }
  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
