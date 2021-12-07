import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:community_app/models/comment_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PerkType {
  undefined,
  freeGiveaway,
  productDrop,
  earnedReward,
  productTest,
  exclusiveProduct,
}

enum Currencies {
  usd,
  euro,
}

// Should there be a product model? Probably... can pull from Shopify for now
// Should there be a product variant model? Probably... can pull from Shopify for now

class PerkModel extends ChangeNotifier {
  String id = "";
  String title = "";
  String productId = "";
  String productName = "";
  double price = 0.0; // in cents
  Currencies currency = Currencies.usd;
  List<String> imageUrls = [];
  DateTime startDate = DateTime(2020, 1, 1, 0, 0, 1);
  DateTime endDate = DateTime(2020, 1, 2, 0, 0, 1);
  DateTime createdAt = DateTime(2020, 1, 1, 0, 0, 1);
  int commentCount = 0;
  PerkType type = PerkType.undefined;

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

  String typeToString() {
    switch (type) {
      case PerkType.freeGiveaway:
        return "FREE GIVEAWAY";
      case PerkType.productDrop:
        return "PRODUCT DROP";
      case PerkType.earnedReward:
        return "EARNED REWARD";
      case PerkType.productTest:
        return "PRODUCT TEST";
      case PerkType.exclusiveProduct:
        return "EXCLUSIVE PRODUCT";
      default:
        return "LOYALTY PERK";
    }
  }

  PerkModel();

  PerkModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    productId = json["productId"];
    imageUrls = json["imageUrls"];
    productName = json["productName"];
    price = json['price'];
    currency = json['currency'];
    type = json['type'];

    if (json.containsKey('startDate')) {
      startDate =
          DateTime.tryParse(json["startDate"]) ?? DateTime(2020, 1, 1, 0, 0, 1);
    }
    if (json.containsKey('endDate')) {
      endDate =
          DateTime.tryParse(json["endDate"]) ?? DateTime(2020, 1, 1, 0, 0, 1);
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
  }
}
