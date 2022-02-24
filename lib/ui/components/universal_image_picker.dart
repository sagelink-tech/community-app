import 'dart:io';
import 'dart:math';
import 'package:collection/src/iterable_extensions.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';

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
  final List<File> _originalImages = [];
  List<String> originalUrls;

  final ImagePicker _picker = ImagePicker();
  int maxImages = 1;
  int targetIndex = 0;
  BuildContext context;
  VoidCallback? onSelected;

  UniversalImagePicker(this.context,
      {this.maxImages = 1, this.onSelected, this.originalUrls = const []}) {
    if (originalUrls.isNotEmpty) {
      initWithOriginalUrls();
    }
  }

  void initWithOriginalUrls() async {
    if (originalUrls.isNotEmpty) {
      for (var url in originalUrls) {
        _originalImages.add(await AssetUtils.urlToFile(url));
      }
    }
    images = List<File>.from(_originalImages);
    if (onSelected != null) {
      onSelected!();
    }
  }

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
              CustomWidgets.buildSnackBar(
                  context,
                  "Selected too many photos. Adding the first $maxImages.",
                  SLSnackBarType.neutral);

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
      // log error
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

  Future<ImageUploadResult> updateImages(String baseKey,
      {String imageKeyPrefix = "image",
      required BuildContext context,
      required GraphQLClient client}) async {
    // Iterate over the new post images:
    //   IF IN ORIGINAL, add URL to new list
    //   ELSE, add to upload queue and save index to be inserted when complete
    List<String> origCachePaths = _originalImages.map((e) => e.path).toList();
    List<int> updateIndices = [];
    List<String> newUrls = [];
    List<File> imagesToBeUploaded = [];

    for (int i = 0; i < min(maxImages, images.length); i++) {
      int origIndex = origCachePaths.indexOf(images[i].path);
      if (origIndex != -1) {
        // is an existing image
        newUrls.add(originalUrls[origIndex]);
      } else {
        // is not an existing image
        // save a null object to be replaced upon completion
        newUrls.add("TMP_HOLDER");
        // add the index to be replaced at
        updateIndices.add(i);
        // add to the images to be uploaded
        imagesToBeUploaded.add(images[i]);
      }
    }

    // TODO Find images to be deleted

    // Upload images
    ImageUploadResult result = await uploadImages(baseKey,
        imageKeyPrefix: imageKeyPrefix,
        context: context,
        client: client,
        imagesToUpload: imagesToBeUploaded);

    // Replace URLs with new URLs
    if (!result.success) {
      return result;
    } else {
      if (updateIndices.length != result.locations.length) {
        throw ErrorDescription(
            "Expected image updates does not equal resulting image updates");
      }
      for (int i = 0; i < result.locations.length; i++) {
        newUrls[updateIndices[i]] = result.locations[i];
      }
      result.locations = newUrls;
      return result;
    }
  }

  Future<ImageUploadResult> uploadImages(String baseKey,
      {String imageKeyPrefix = "image",
      required BuildContext context,
      required GraphQLClient client,
      List<File>? imagesToUpload}) async {
    imagesToUpload ??= images;
    List<MultipartFile> files = [];
    var uuid = Uuid();

    bool singleFileUpload = maxImages == 1 || imagesToUpload.length == 1;

    if (!singleFileUpload) {
      for (var i = 0; i < imagesToUpload.length; i++) {
        var filename =
            "${baseKey.replaceAll("/", "__")}${imageKeyPrefix}_${uuid.v4()}${path.extension(imagesToUpload[i].path)}";
        files.add(convertImageToMultipartFiles(imagesToUpload[i], filename));
      }
    } else {
      var filename =
          "${baseKey.replaceAll("/", "__")}${imageKeyPrefix}_${uuid.v4()}${path.extension(imagesToUpload[0].path)}";
      files.add(convertImageToMultipartFiles(imagesToUpload[0], filename));
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
      CustomWidgets.buildSnackBar(
          context, "Error uploading images", SLSnackBarType.error);

      return ImageUploadResult(false, []);
    }

    // Parse results
    if (singleFileUpload) {
      return ImageUploadResult(!(result.hasException || result.data == null),
          [result.data!['singleUpload']['location']]);
    } else {
      ImageUploadResult tmpResult = ImageUploadResult(true, []);
      for (var el in (result.data!['multipleUpload'] as List)) {
        tmpResult.success == (tmpResult.success && el['success'] == "true");
        tmpResult.locations.add(el['location']);
      }
      return tmpResult;
    }
  }
}
