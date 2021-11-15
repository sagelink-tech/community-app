import 'package:community_app/models/post_model.dart';

import 'base_command.dart';

class GetPostsCommand extends BaseCommand {
  Future<List<PostModel>> run(String? brandId) async {
    // Make service call and inject results into the model
    List<PostModel> posts = await userService.getPosts(brandId);

    // Return our posts to the caller in case they care
    return posts;
  }
}
