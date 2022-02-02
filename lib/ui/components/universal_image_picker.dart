import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

// NOTE:
// Images use a __ in the filename as a replacement
// for a / in the final path on S3.
// So if it is to be in brand/<brand_id>/banner.jpg
// the upload filename should be:
// brand__<brand_id>__banner.jpg

String uploadPhotoMutation = """
mutation SingleUpload(\$file: Upload!) {
  singleUpload(file: \$file) {
    success
    message
    mimetype
    encoding
    filename
    location
  }
}
""";

String uploadMultiPhotoMutation = """
mutation MultipleUpload(\$files: [Upload!]!) {
  multipleUpload(files: \$files) {
    success
    message
    mimetype
    encoding
    filename
    location
  }
}
""";

class ImageUploadResult {
  bool success;
  List<String> locations = [];

  ImageUploadResult(this.success, this.locations);
}

class UniversalImagePicker {
  List<File> images = [];
  final ImagePicker _picker = ImagePicker();
  int maxImages = 1;
  int targetIndex = 0;
  BuildContext context;
  VoidCallback? onSelected;

  UniversalImagePicker(this.context, {this.maxImages = 1, this.onSelected});

  void clearImages() {
    images = [];
    if (onSelected != null) {
      onSelected!();
    }
  }

  void removeImageAtIndex(int index) {
    if (index >= images.length) {
      return;
    }
    images.removeAt(index);
    if (onSelected != null) {
      onSelected!();
    }
  }

  void openImagePicker() async {
    if (kIsWeb) {
      // web image picker
      _imgFromSource(ImageSource.gallery, maxImages);
    } else {
      // mobile image picker
      _showPicker();
    }
  }

  void _imgFromSource(ImageSource source, int maxImages) async {
    List<File> selection = maxImages > 1 ? images : [];
    try {
      if (source == ImageSource.gallery && maxImages > 1) {
        List<XFile>? xfiles = await _picker.pickMultiImage(
            maxHeight: 1024, maxWidth: 1024, imageQuality: 80);
        if (xfiles != null) {
          for (var xf in xfiles) {
            if (selection.length >= maxImages) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Selected too many photos. Adding the first $maxImages."),
                  backgroundColor: Theme.of(context).colorScheme.error));
              break;
            }
            selection.add(File(xf.path));
          }
        }
      } else {
        XFile? xfile = await _picker.pickImage(
            source: source, maxHeight: 1024, maxWidth: 1024, imageQuality: 80);
        if (xfile != null) {
          selection.add(File(xfile.path));
        }
      }
    } catch (e) {
      print(e);
    } finally {
      images = selection;
      if (onSelected != null) {
        onSelected!();
      }
    }
  }

  void _showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromSource(ImageSource.gallery, maxImages);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromSource(ImageSource.camera, maxImages);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  MultipartFile convertImageToMultipartFiles(File image, String newFilename) {
    var byteData = image.readAsBytesSync();
    var multipartFile = MultipartFile.fromBytes('photo', byteData,
        filename: newFilename,
        contentType:
            MediaType("image", path.extension(newFilename).substring(1)));
    return multipartFile;
  }

  Future<ImageUploadResult> uploadImages(String baseKey,
      {String imageKeyPrefix = "image",
      required BuildContext context,
      required GraphQLClient client}) async {
    // if (images.isEmpty) {
    //   return null;
    // }

    List<MultipartFile> files = [];

    bool singleFileUpload = maxImages == 1 || images.length == 1;

    if (!singleFileUpload) {
      for (var i = 0; i < images.length; i++) {
        var filename =
            "${baseKey.replaceAll("/", "__")}${imageKeyPrefix}_$i${path.extension(images[i].path)}";
        files.add(convertImageToMultipartFiles(images[i], filename));
      }
    } else {
      var filename =
          "${baseKey.replaceAll("/", "__")}$imageKeyPrefix${path.extension(images[0].path)}";
      files.add(convertImageToMultipartFiles(images[0], filename));
    }

    Map<String, dynamic> variables = singleFileUpload
        ? {"file": files[0], "basePath": baseKey.replaceAll("/", "__")}
        : {"files": files, "basePath": baseKey.replaceAll("/", "__")};

    MutationOptions options = MutationOptions(
        document: singleFileUpload
            ? gql(uploadPhotoMutation)
            : gql(uploadMultiPhotoMutation),
        variables: variables);

    QueryResult result = await client.mutate(options);
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Error uploading images"),
          backgroundColor: Theme.of(context).colorScheme.error));
      return ImageUploadResult(false, []);
    }

    // Parse results
    if (singleFileUpload) {
      return ImageUploadResult(!(result.hasException || result.data == null),
          [result.data!['singleUpload']['location']]);
    } else {
      ImageUploadResult results = ImageUploadResult(true, []);
      for (var el in (result.data!['multipleUpload'] as List)) {
        results.success == (results.success && el['success'] == "true");
        results.locations.add(el['location']);
      }
      return results;
    }
  }
}
