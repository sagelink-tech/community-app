import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class EmbeddedImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool showFullscreenButton;
  const EmbeddedImageCarousel(this.imageUrls,
      {this.height = 100.0, this.showFullscreenButton = true, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EmbeddedImageCarouselState();
  }
}

class _EmbeddedImageCarouselState extends State<EmbeddedImageCarousel> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  void _showFullScreen(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FullPageImageCarousel(
                  widget.imageUrls,
                  startIndex: _current,
                )));
  }

  List<Widget> _buildImages() {
    return widget.imageUrls.isNotEmpty
        ? widget.imageUrls
            .map((imageUrl) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholderFadeInDuration: const Duration(milliseconds: 10),
                  placeholder: (context, url) => AssetUtils.wrappedDefaultImage(
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: widget.height,
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: widget.height,
                )))
            .toList()
        : [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: AssetUtils.defaultImage(
                  width: double.infinity,
                  height: widget.height,
                ))
          ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [
      CarouselSlider(
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
      ),
    ];

    if (widget.showFullscreenButton) {
      stackChildren.add(Container(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.photo_camera),
            label: Text(widget.imageUrls.length.toString() +
                (widget.imageUrls.length == 1 ? " Photo" : " Photos")),
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).backgroundColor,
                onPrimary: Theme.of(context).colorScheme.onBackground),
            onPressed: widget.imageUrls.isNotEmpty
                ? () => _showFullScreen(context)
                : null,
          )));
    }

    return Stack(alignment: Alignment.bottomRight, children: stackChildren);
  }
}

class FullPageImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final int startIndex;
  const FullPageImageCarousel(this.imageUrls, {this.startIndex = 0, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FullPageImageCarouselState();
  }
}

class _FullPageImageCarouselState extends State<FullPageImageCarousel> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    _current = widget.startIndex;
  }

  void _closePage(BuildContext context) {
    Navigator.pop(context);
  }

  List<Widget> _buildImages(height, width) {
    return widget.imageUrls
        .map((imageUrl) =>
            Stack(alignment: Alignment.center, children: <Widget>[
              CachedNetworkImage(
                imageUrl: imageUrl,
                imageBuilder: (context, imageProvider) => PhotoView(
                  imageProvider: imageProvider,
                ),
                placeholderFadeInDuration: const Duration(milliseconds: 10),
                placeholder: (context, url) => AssetUtils.wrappedDefaultImage(
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: height,
                ),
              ),
              Container(
                  height: height,
                  width: width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x77000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0x77000000),
                      ],
                    ),
                  ))
            ]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(alignment: Alignment.topRight, children: [
          CarouselSlider(
            items: _buildImages(height, width),
            carouselController: _controller,
            options: CarouselOptions(
                autoPlay: false,
                initialPage: widget.startIndex,
                height: height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
          Container(
              padding: const EdgeInsets.all(20),
              child: IconButton(
                icon: const DecoratedIcon(
                  Icons.close,
                  color: Colors.white,
                  shadows: [
                    BoxShadow(
                      blurRadius: 42.0,
                      color: Colors.black,
                    ),
                  ],
                ),
                onPressed: () => _closePage(context),
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageUrls.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              )),
        ]));
  }
}
