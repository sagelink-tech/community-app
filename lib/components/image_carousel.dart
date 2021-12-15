import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class EmbeddedImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  const EmbeddedImageCarousel(this.imageUrls, {this.height = 100.0, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EmbeddedImageCarouselState();
  }
}

class _EmbeddedImageCarouselState extends State<EmbeddedImageCarousel> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  List<Widget> _buildImages() {
    return widget.imageUrls
        .map((imageUrl) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: widget.height,
            )))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: _buildImages(),
      carouselController: _controller,
      options: CarouselOptions(
          autoPlay: false,
          height: widget.height,
          viewportFraction: 0.8,
          enlargeCenterPage: false,
          enableInfiniteScroll: false,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
    );
  }
}
