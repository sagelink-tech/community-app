import 'dart:math';
import 'dart:convert';
import 'package:community_app/models/brand_model.dart';
import 'package:community_app/models/user_model.dart';

const String brandData = '''
[
    {
      "id": "100",
      "name": "Sakara Life",
      "description": "Sells stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following",
      "mainColor": "#35654e"
    },
    {
      "id": "101",
      "name": "Haus Liquor",
      "description": "Sells some stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "VIP Tier",
      "mainColor": "#000000"
    },
    {
      "id": "102",
      "name": "Acapella",
      "description": "Sells different stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Loyalist",
      "mainColor": "#38383b"
    },
    {
      "id": "103",
      "name": "Pricklee",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Newcomer",
      "mainColor": "#192862"
    },
    {
      "id": "104",
      "name": "Brand 5",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "105",
      "name": "Brand 6",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "106",
      "name": "Brand 7",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "107",
      "name": "Brand 8",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "108",
      "name": "Brand 9",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "109",
      "name": "Brand 10",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "110",
      "name": "Brand 11",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "111",
      "name": "Brand 12",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    },
    {
      "id": "112",
      "name": "Brand 13",
      "description": "Sells drink stuff.",
      "logoUrl": "http://logo.url",
      "website": "http://google.com",
      "relationship": "Following"
    }
]
''';

const userData = '''
{
  "id": "001",
  "username": "TestAccount",
  "name": "Test User",
  "email": "test@test.com",
  "accountPictureUrl": "http://logo.url"
}
''';

class UserService {
  Future<bool> login(String user, String pass) async {
    // Fake a network service call, and return true
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<UserModel> getUserAccount(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel.fromJson(json.decode(userData));
  }

  Future<List<String>> getPosts(String user) async {
    // Fake a service call, and return some posts
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(50, (index) => "Item ${Random().nextInt(999)}}");
  }

  Future<List<BrandModel>> getBrands(String user) async {
    await Future.delayed(const Duration(seconds: 1));
    var brands = json.decode(brandData);
    List<BrandModel> brandModels = [];
    for (var brand in brands) {
      brandModels.add(BrandModel.fromJson(brand));
    }
    return brandModels;
  }

  Future<BrandModel?> getBrand(String brandId) async {
    await Future.delayed(const Duration(seconds: 1));
    var brands = json.decode(brandData);
    for (var b in brands) {
      if (b['id'] == brandId) {
        return BrandModel.fromJson(b);
      }
    }
    return null;
  }
}
