import 'package:community_app/models/brand_model.dart';

import 'base_command.dart';

class GetBrandsCommand extends BaseCommand {
  Future<List<BrandModel>> run(String user) async {
    // Make service call and inject results into the model
    List<BrandModel> brands = await userService.getBrands(user);
    userModel.brands = brands;

    // Return our posts to the caller in case they care
    return brands;
  }
}
