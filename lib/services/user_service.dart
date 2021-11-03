import 'dart:math';
import 'dart:convert';
import 'package:community_app/models/brand_model.dart';

const String data = '''
[
    {
        "name": "Sakara Life",
        "description": "Sells stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following",
        "mainColor": "#35654e"
    },
    {
        "name": "Haus Liquor",
        "description": "Sells some stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "VIP Tier",
        "mainColor": "#000000"
    },
    {
        "name": "Acapella",
        "description": "Sells different stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Loyalist",
        "mainColor": "#38383b"
    },
    {
        "name": "Pricklee",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Newcomer",
        "mainColor": "#192862"
    },
    {
        "name": "Brand 5",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 6",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 7",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 8",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 9",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 10",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 11",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 12",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    },
    {
        "name": "Brand 13",
        "description": "Sells drink stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com",
        "relationship": "Following"
    }
]
''';

class UserService {
  Future<bool> login(String user, String pass) async {
    // Fake a network service call, and return true
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<List<String>> getPosts(String user) async {
    // Fake a service call, and return some posts
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(50, (index) => "Item ${Random().nextInt(999)}}");
  }

  Future<List<BrandModel>> getBrands(String user) async {
    await Future.delayed(const Duration(seconds: 1));
    var brands = json.decode(data);
    List<BrandModel> brandModels = [];
    for (var brand in brands) {
      brandModels.add(BrandModel.fromJson(brand));
    }
    return brandModels;
  }
}
