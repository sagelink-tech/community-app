import 'package:community_app/models/user_model.dart';

import 'base_command.dart';

class GetUserAccount extends BaseCommand {
  Future<UserModel?> run(String userId) async {
    // Make service call and inject results into the model
    UserModel? user = await userService.getUserAccount(userId);

    // Return our posts to the caller in case they care
    return user;
  }
}
