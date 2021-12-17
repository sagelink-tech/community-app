import 'package:sagelink_communities/models/user_model.dart';
import 'package:sagelink_communities/utils/color_utils.dart';
import 'package:flutter/material.dart';

class BrandModel extends ChangeNotifier {
  String id = "df487c75-7186-48ea-a507-25b80aa92c64";
  String name = "brand name";
  String description = "brand description";
  String logoUrl = "";
  String backgroundImageUrl = "";
  String website = "www.brand.com";
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
    mainColor = json.containsKey('mainColor') && json['mainColor'] != null
        ? ColorUtils.parseHex((json['mainColor']))
        : Colors.blueGrey;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'backgroundImageUrl': backgroundImageUrl,
        'website': website,
        'mainColor': ColorUtils.hexValue(mainColor),
      };
  // Eventually other stuff would go here, notifications, friends, draft posts, etc
}
