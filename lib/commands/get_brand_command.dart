import 'package:community_app/models/brand_model.dart';

import 'base_command.dart';

class GetBrandCommand extends BaseCommand {
  Future<BrandModel?> run(String brandId) async {
    // Make service call and inject results into the model
    BrandModel? brand = await userService.getBrand(brandId);

    // Return our posts to the caller in case they care
    return brand;
  }
}
