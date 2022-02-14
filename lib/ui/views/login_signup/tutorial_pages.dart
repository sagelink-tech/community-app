import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/utils/asset_utils.dart';

class TutorialPage {
  String text;
  Widget image;

  TutorialPage(this.text, this.image);
}

class TutorialPages extends StatefulWidget {
  final VoidCallback onComplete;
  const TutorialPages({required this.onComplete, Key? key}) : super(key: key);

  @override
  _TutorialPagesState createState() => _TutorialPagesState();
}

class _TutorialPagesState extends State<TutorialPages>
    with SingleTickerProviderStateMixin {
  //Your animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<TutorialPage> _pages = [
    TutorialPage("Page 1", AssetUtils.wrappedDefaultImage()),
    TutorialPage("Page 2", AssetUtils.wrappedDefaultImage()),
    TutorialPage("Page 3", AssetUtils.wrappedDefaultImage()),
  ];

  late List<Widget> _pageWidgets;

  @override
  void initState() {
    _pageWidgets = _pages
        .map((p) => Stack(alignment: Alignment.center, children: <Widget>[
              p.image,
              Center(child: Text(p.text)),
            ]))
        .toList();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    //Implement animation here
    _animation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _current = 0;
  final CarouselController _controller = CarouselController();

  Widget _buildButton() {
    bool isLast = _current == _pages.length - 1;
    return isLast
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => widget.onComplete(),
            child: const Text("Done"))
        : OutlinedButton(
            onPressed: () => _controller.animateToPage(_current + 1),
            child: const Text("Next"));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Hero(
            tag: "heroLogo",
            //FadeTransition makes your image Fade
            child: FadeTransition(
                //Use your animation here
                opacity: _animation,
                child: Stack(alignment: Alignment.topRight, children: [
                  CarouselSlider(
                    items: _pageWidgets,
                    carouselController: _controller,
                    options: CarouselOptions(
                        autoPlay: false,
                        initialPage: 0,
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
                      padding: const EdgeInsets.only(top: 40, right: 25),
                      child: _buildButton()),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _pages.asMap().entries.map((entry) {
                          return Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(
                                      _current == entry.key ? 0.9 : 0.4)));
                        }).toList(),
                      )),
                ]))));
  }
}
