import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:sagelink_communities/data/models/brand_model.dart';
import 'package:sagelink_communities/data/models/cause_model.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';

class UserModel extends ChangeNotifier {
  String id = "123";
  String firebaseId = "123";
  String description = "description";
  String name = "full name";
  String email = "email@email.com";
  String accountPictureUrl = "";
  DateTime createdAt = DateTime(2020, 1, 1, 0, 0);
  bool queryUserIsBlocked = false;
  bool queryUserHasBlocked = false;

  Image profileImage() => accountPictureUrl.isNotEmpty
      ? Image.network(
          accountPictureUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        )
      : AssetUtils.defaultImage();

  List<String> _userPosts = [];

  List<String> get userPosts => _userPosts;

  set userPosts(List<String> userPosts) {
    _userPosts = userPosts;
    notifyListeners();
  }

  // Brands
  List<BrandModel> _brands = [];
  List<BrandModel> get brands => _brands;

  set brands(List<BrandModel> brands) {
    _brands = brands;
    notifyListeners();
  }

  // Causes
  List<CauseModel> _causes = [];
  List<CauseModel> get causes => _causes;
  set causes(List<CauseModel> causes) {
    _causes = causes;
    notifyListeners();
  }

  UserModel();

  UserModel.fromFirebaseUser(User user) {
    id = "NO_SL_ID";
    name = user.displayName ?? "";
    accountPictureUrl = user.photoURL ?? "";
    email = user.email ?? "";
    firebaseId = user.uid;
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firebaseId = json.containsKey('firebaseId') ? json['firebaseId'] ?? "" : "";
    description =
        json.containsKey('description') ? json['description'] ?? "" : "";
    name = json.containsKey('name') ? json['name'] ?? "" : "";
    email = json.containsKey('email') ? json['email'] ?? "" : "";
    if (json.containsKey('createdAt')) {
      createdAt =
          DateTime.tryParse(json["createdAt"]) ?? DateTime(2020, 1, 1, 0, 0, 1);
    }
    if (json.containsKey('queryUserHasBlocked')) {
      queryUserHasBlocked = json['queryUserHasBlocked'];
    }
    if (json.containsKey('queryUserIsBlocked')) {
      queryUserIsBlocked = json['queryUserIsBlocked'];
    }
    accountPictureUrl = json.containsKey('accountPictureUrl')
        ? json['accountPictureUrl'] ?? ""
        : "";

    if (json.containsKey('causes')) {
      List<CauseModel> _c = [];
      for (var c in json['causes']) {
        _c.add(CauseModel(c['id'], c['title']));
      }
      causes = _c;
    }

    // add brands if their in the json
    _brands = [];
    if (json.containsKey('memberOfBrands')) {
      List<BrandModel> _b = [];
      for (var b in json['memberOfBrands']) {
        _b.add(BrandModel.fromJson(b));
      }
      _brands.addAll(_b);
    }
    if (json.containsKey('employeeOfBrands')) {
      List<BrandModel> _b = [];
      for (var b in json['employeeOfBrands']) {
        _b.add(BrandModel.fromJson(b));
      }
      _brands.addAll(_b);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'accountPictureUrl': accountPictureUrl
      };
}

class EmployeeModel extends UserModel {
  List<String> roles = [];
  bool founder = false;
  bool owner = false;
  String jobTitle = "";
  EmployeeModel() : super();

  @override
  EmployeeModel.fromJson(Map<String, dynamic> json) {
    //UserModel.fromJson(json);
    id = json['id'];
    firebaseId = json.containsKey('firebaseId') ? json['firebaseId'] ?? "" : "";
    description =
        json.containsKey('description') ? json['description'] ?? "" : "";
    name = json.containsKey('name') ? json['name'] ?? "" : "";
    email = json.containsKey('email') ? json['email'] ?? "" : "";
    if (json.containsKey('createdAt')) {
      createdAt =
          DateTime.tryParse(json["createdAt"]) ?? DateTime(2020, 1, 1, 0, 0, 1);
    }
    if (json.containsKey('queryUserHasBlocked')) {
      queryUserHasBlocked = json['queryUserHasBlocked'];
    }
    if (json.containsKey('queryUserIsBlocked')) {
      queryUserIsBlocked = json['queryUserIsBlocked'];
    }
    accountPictureUrl = json.containsKey('accountPictureUrl')
        ? json['accountPictureUrl'] ?? ""
        : "";
    Map<String, dynamic>? _employeeJson;
    if (json.containsKey('employeeOfBrandsConnection')) {
      _employeeJson = json["employeeOfBrandsConnection"]["edges"][0];
    }
    roles = List<String>.from(json["roles"] ?? _employeeJson?["roles"] ?? "");
    founder = json['founder'] ?? _employeeJson?["founder"] ?? false;
    owner = json['owner'] ?? _employeeJson?["owner"] ?? "";
    jobTitle = json['jobTitle'] ?? _employeeJson?["jobTitle"] ?? "";

    if (json.containsKey('causes')) {
      List<CauseModel> _c = [];
      for (var c in json['causes']) {
        _c.add(CauseModel(c['id'], c['title']));
      }
      causes = _c;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var _json = super.toJson();
    _json['roles'] = roles;
    _json['founder'] = founder;
    _json['owner'] = owner;
    _json['jobTitle'] = jobTitle;
    return _json;
  }
}

class MemberModel extends UserModel {
  String tier = "";
  bool isFlagged = false;
  bool isBanned = false;
  DateTime memberSince = DateTime(2020);
  String customerId = "";
  MemberModel() : super();

  @override
  MemberModel.fromJson(Map<String, dynamic> json, String brandId) {
    //UserModel.fromJson(json);
    id = json['id'];
    firebaseId = json.containsKey('firebaseId') ? json['firebaseId'] ?? "" : "";
    description =
        json.containsKey('description') ? json['description'] ?? "" : "";
    name = json.containsKey('name') ? json['name'] ?? "" : "";
    email = json.containsKey('email') ? json['email'] ?? "" : "";
    if (json.containsKey('createdAt')) {
      createdAt =
          DateTime.tryParse(json["createdAt"]) ?? DateTime(2020, 1, 1, 0, 0, 1);
    }
    if (json.containsKey('queryUserHasBlocked')) {
      queryUserHasBlocked = json['queryUserHasBlocked'];
    }
    if (json.containsKey('queryUserIsBlocked')) {
      queryUserIsBlocked = json['queryUserIsBlocked'];
    }
    accountPictureUrl = json.containsKey('accountPictureUrl')
        ? json['accountPictureUrl'] ?? ""
        : "";
    if (json.containsKey('tier')) {
      tier = json['tier'] ?? "";
    } else if (json.containsKey("memberOfBrandsConnection")) {
      Map<String, dynamic> memberInfo =
          json['memberOfBrandsConnection']['edges'][0];
      // parse membership info
      tier = memberInfo["tier"] ?? "";
      customerId = memberInfo["customerId"] ?? "";
      memberSince =
          DateTime.tryParse(memberInfo["createdAt"]) ?? DateTime(2020);
    }
    // check if flagged
    if (json.containsKey('flaggedInBrands')) {
      if ((json['flaggedInBrands'] as List).isNotEmpty) {
        for (var b in (json['flaggedInBrands'] as List)) {
          if (b['id'] == brandId) {
            isFlagged = true;
            break;
          }
        }
      }
    }
    // check if banned
    if (json.containsKey('bannedFromBrands')) {
      if ((json['bannedFromBrands'] as List).isNotEmpty) {
        for (var b in (json['bannedFromBrands'] as List)) {
          if (b['id'] == brandId) {
            isBanned = true;
            break;
          }
        }
      }
    }

    if (json.containsKey('causes')) {
      List<CauseModel> _c = [];
      for (var c in json['causes']) {
        _c.add(CauseModel(c['id'], c['title']));
      }
      causes = _c;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var _json = super.toJson();
    _json['tier'] = tier;
    return _json;
  }
}
