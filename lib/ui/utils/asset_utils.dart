import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class AssetUtils {
  static Image defaultImage(
          {BoxFit fit = BoxFit.cover, double? width, double? height}) =>
      Image(
        image: const AssetImage('assets/default_image.png'),
        fit: fit,
        width: width,
        height: height,
      );
  static Widget wrappedDefaultImage(
          {BoxFit fit = BoxFit.cover, double? width, double? height}) =>
      SizedBox(
          width: width,
          height: height,
          child: Image(
            image: const AssetImage('assets/default_image.png'),
            fit: fit,
            width: double.infinity,
            height: double.infinity,
          ));

  static Future<File> urlToFile(String imageUrl) async {
    // get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
    // get temporary path from temporary directory.
    String tempPath = tempDir.path;
    // create a new file in temporary path with random file name.
    File file = File(tempPath + basename(imageUrl).split("?")[0]);
    // call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
    // write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
    // now return the file which is created with random name in
    // temporary directory and image bytes from response is written to // that file.
    return file;
  }
}
