import 'dart:math';
import 'dart:convert';
import 'package:community_app/models/brand_model.dart';

const String data = '''
[
    {
        "name": "Brand 1",
        "description": "Sells stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com"
    },
    {
        "name": "Brand 2",
        "description": "Sells some stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com"
    },
    {
        "name": "Brand 3",
        "description": "Sells different stuff.",
        "logoUrl": "http://logo.url",
        "website": "http://google.com"
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
