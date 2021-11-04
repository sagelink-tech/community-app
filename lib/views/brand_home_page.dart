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
  bool _isLoading = true;
  BrandModel brand = BrandModel();

  void _loadBrand() async {
    // Disable the RefreshBtn while the Command is running
    setState(() => _isLoading = true);
    // Run command

    var updated = await GetBrandCommand().run(widget.brandId);
    if (updated != null) {
      brand = updated;
    }

    // Re-enable refresh btn when command is done
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadBrand();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading ? const Text('Loading') : Text(brand!.name),
        backgroundColor: brand.mainColor,
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
          child: (_isLoading
              ? const CircularProgressIndicator()
              : Text(brand.description))),
    );
  }
}
