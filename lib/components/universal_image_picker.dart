import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UniversalImagePicker {
  List<File> images = [];
  dynamic picker;
  int maxImages = 1;
  int targetIndex = 0;
  BuildContext context;
  VoidCallback? onSelected;

  UniversalImagePicker(this.context, {this.maxImages = 1, this.onSelected});

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
    List<File> selection = [];
    if (source == ImageSource.gallery && maxImages > 1) {
      List<XFile>? xfiles = await ImagePicker().pickMultiImage();
      if (xfiles != null) {
        for (var xf in xfiles) {
          selection.add(File(xf.path));
        }
      }
    } else {
      XFile? xfile = await ImagePicker().pickImage(source: source);
      if (xfile != null) {
        selection.add(File(xfile.path));
      }
    }
    images = selection;
    if (onSelected != null) {
      print("Should show image");
      onSelected!();
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
                    _imgFromSource(ImageSource.gallery, maxImages);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
