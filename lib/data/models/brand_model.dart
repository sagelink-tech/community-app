import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:sagelink_communities/data/models/cause_model.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';
import 'package:sagelink_communities/ui/utils/color_utils.dart';
import 'package:flutter/material.dart';

class BrandLink {
  final String id;
  final String title;
  final String url;
  const BrandLink(this.id, this.title, this.url);
}

class BrandModel extends ChangeNotifier {
  String id = "df487c75-7186-48ea-a507-25b80aa92c64";
  String firebaseId = "df487c75-7186-48ea-a507-25b80aa92c64";
  String name = "brand name";
  String description = "brand description";
  String logoUrl = "";
  String backgroundImageUrl = "";
  String website = "www.brand.com";
  Color mainColor = Colors.blueGrey;

  Image bannerImage() => backgroundImageUrl.isNotEmpty
      ? Image.network(
          backgroundImageUrl,
          fit: BoxFit.fitWidth,
          width: double.infinity,
        )
      : AssetUtils.defaultImage();

  Image logoImage() => logoUrl.isNotEmpty
      ? Image.network(
          logoUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        )
      : AssetUtils.defaultImage();

  // Employees
  List<EmployeeModel> _employees = [];

  List<EmployeeModel> get employees => _employees;

  set employees(List<EmployeeModel> employees) {
    _employees = employees;
    notifyListeners();
  }

  int employeeCount = 0;

  // Members
  List<UserModel> _members = [];

  List<UserModel> get members => _members;

  set members(List<UserModel> members) {
    _members = members;
    notifyListeners();
  }

  int memberCount = 0;

  // Causes
  List<CauseModel> _causes = [];
  List<CauseModel> get causes => _causes;
  set causes(List<CauseModel> causes) {
    _causes = causes;
    notifyListeners();
  }

  // helpers
  int get totalCommunityCount => employeeCount + memberCount;

  //constructors

  BrandModel();

  BrandModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json.containsKey('description') ? json['description'] : "";
    logoUrl = json.containsKey('logoUrl') ? json['logoUrl'] ?? "" : "";
    backgroundImageUrl = json.containsKey('backgroundImageUrl')
        ? json['backgroundImageUrl'] ?? ""
        : "";
    website = json.containsKey('website') ? json['website'] : "";
    mainColor = json.containsKey('mainColor') && json['mainColor'] != null
        ? ColorUtils.parseHex((json['mainColor']))
        : Colors.blueGrey;

    employeeCount = json.containsKey('employeesConnection')
        ? json['employeesConnection']['totalCount']
        : 0;
    memberCount = json.containsKey('membersConnection')
        ? json['membersConnection']['totalCount']
        : 0;

    if (json.containsKey('employeesConnection') &&
        (json['employeesConnection'] as Map).containsKey('edges')) {
      List<EmployeeModel> _emps = [];
      for (Map e in json['employeesConnection']['edges']) {
        var _json = e['node'];
        for (var key in e.keys) {
          if (key != ' node') {
            _json[key] = e[key];
          }
        }
        _emps.add(EmployeeModel.fromJson(_json));
      }
      employees = _emps;
    }

    if (json.containsKey('membersConnection') &&
        (json['membersConnection'] as Map).containsKey('edges')) {
      List<MemberModel> _membs = [];
      for (var e in json['membersConnection']['edges']) {
        var _json = e['node'];
        for (var key in e.keys) {
          if (key != ' node') {
            _json[key] = e[key];
          }
        }
        _membs.add(MemberModel.fromJson(e['node']));
      }
      members = _membs;
    }

    if (json.containsKey('causes')) {
      List<CauseModel> _c = [];
      for (var c in json['causes']) {
        _c.add(CauseModel(c['id'], c['title']));
      }
      causes = _c;
    }
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
