import 'package:community_app/models/user_model.dart';
import 'package:community_app/utils/color_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BrandModel extends ChangeNotifier {
  String id = "";
  String name = "";
  String description = "";
  String logoUrl = "";
  String backgroundImageUrl = "";
  String website = "";
  String relationship = "";
  Color mainColor = Colors.blueGrey;

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

  BrandModel();

  BrandModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json.containsKey('description') ? json['description'] : "";
    logoUrl = json.containsKey('logoUrl') ? json['logoUrl'] : "";
    backgroundImageUrl = json.containsKey('backgroundImageUrl')
        ? json['backgroundImageUrl']
        : "";
    website = json.containsKey('website') ? json['website'] : "";
    relationship = json.containsKey('relationship') ? json['relationship'] : "";
    mainColor = json.containsKey('mainColor') && json['mainColor'] != null
        ? ColorUtils.parseHex((json['mainColor']))
        : Colors.blueGrey;
  }
  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
