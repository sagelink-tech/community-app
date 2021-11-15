import 'dart:math';
import 'dart:convert';
import 'package:community_app/models/post_model.dart';
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

const postData = '''
[
  {
    "id": "001",
    "title": "Test Post",
    "description": "Post Description",
    "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ac maximus mauris. Pellentesque vestibulum fringilla eros ut eleifend. Donec fringilla erat ut dolor maximus lacinia. Praesent blandit magna sem, et ultrices turpis fermentum eget. Pellentesque pellentesque faucibus ipsum. Nulla lacinia lorem tempor, ornare magna non, pharetra felis. Nam sollicitudin metus lacus, faucibus rhoncus neque sollicitudin a. Suspendisse ut neque elementum lacus pretium bibendum vel aliquam eros. Suspendisse non condimentum velit. In facilisis, velit et bibendum ornare, quam nisl pharetra neque, in interdum mi sapien in lacus. In eget nunc finibus, vulputate dui ut, iaculis magna. Ut bibendum eleifend accumsan.",
    "embeddedUrl": "",
    "imageUrl": "",
    "type": 1,
    "brand": "101",
    "creator": "001"
  },
  {
    "id": "002",
    "title": "Test Post 2",
    "description": "Post Description",
    "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ac maximus mauris. Pellentesque vestibulum fringilla eros ut eleifend. Donec fringilla erat ut dolor maximus lacinia. Praesent blandit magna sem, et ultrices turpis fermentum eget. Pellentesque pellentesque faucibus ipsum. Nulla lacinia lorem tempor, ornare magna non, pharetra felis. Nam sollicitudin metus lacus, faucibus rhoncus neque sollicitudin a. Suspendisse ut neque elementum lacus pretium bibendum vel aliquam eros. Suspendisse non condimentum velit. In facilisis, velit et bibendum ornare, quam nisl pharetra neque, in interdum mi sapien in lacus. In eget nunc finibus, vulputate dui ut, iaculis magna. Ut bibendum eleifend accumsan.",
    "embeddedUrl": "",
    "imageUrl": "",
    "type": 1,
    "brand": "102",
    "creator": "001"
  }
]
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

  Future<List<BrandModel>> getBrands(String user) async {
    await Future.delayed(const Duration(seconds: 1));
    var brands = json.decode(brandData);
    List<BrandModel> brandModels = [];
    for (var brand in brands) {
      brandModels.add(BrandModel.fromJson(brand));
    }
    return brandModels;
  }

  Future<BrandModel> getBrand(String brandId) async {
    await Future.delayed(const Duration(seconds: 1));
    var brands = json.decode(brandData);
    for (var b in brands) {
      if (b['id'] == brandId) {
        return BrandModel.fromJson(b);
      }
    }
    //Default to the simple constructor if no brand is found
    return BrandModel();
  }

  Future<List<PostModel>> getPosts(String? brandId) async {
    await Future.delayed(const Duration(seconds: 1));
    var posts = json.decode(postData) as List;
    List<PostModel> postModels = [];

    if (brandId != null) {
      posts = posts.where((p) => p['brand'] == brandId).toList();
    }

    for (var p in posts) {
      var post = PostModel.fromJson(p);
      post.brand = await getBrand(p['brand']);
      post.creator = await getUserAccount(p['creator']);
      postModels.add(post);
    }
    return postModels;
  }
}
