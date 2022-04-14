import 'package:flutter/material.dart';

class GalleryImageWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onImageTap;

  const GalleryImageWidget(
      {Key? key, required this.imageUrl, required this.onImageTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Material(
          child: Ink.image(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            child: InkWell(onTap: onImageTap),
          ),
        ),
      ),
    );
  }
}