import 'package:flutter/material.dart';
import 'package:community_app/commands/get_brand_command.dart';
import 'package:community_app/models/brand_model.dart';

class BrandHomepage extends StatefulWidget {
  const BrandHomepage({Key? key, required this.brandId}) : super(key: key);
  final String brandId;

  static const routeName = '/brands';

  @override
  _BrandHomepageState createState() => _BrandHomepageState();
}

class _BrandHomepageState extends State<BrandHomepage> {
  bool _isLoading = false;
  BrandModel? brand;

  void _loadBrand() async {
    if (_isLoading) {
      return;
    }
    // Disable the RefreshBtn while the Command is running
    setState(() => _isLoading = true);
    // Run command

    brand = await GetBrandCommand().run(widget.brandId);

    // Re-enable refresh btn when command is done
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: brand == null ? const Text('Loading') : Text(brand!.name),
        backgroundColor: brand == null ? Colors.blueGrey : brand!.mainColor,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: _isLoading ? null : _loadBrand,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
      body: Center(
          child: (brand == null
              ? const CircularProgressIndicator()
              : Text(brand!.description))),
    );
  }
}
