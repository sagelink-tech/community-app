import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';

class TutorialPage {
  String title;
  String subtitle;
  Widget image;

  TutorialPage(this.title, this.subtitle, this.image);
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
    TutorialPage(
        "Authentic conversations with the people who shop at your favorite brands",
        "And access to exclusive products, free, giveaways, product testing, and more!",
        const Image(
            image: AssetImage('assets/convo_image.png'),
            fit: BoxFit.scaleDown,
            height: 125)),
  ];

  List<Widget> _pageWidgets = [];

  @override
  void initState() {
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      setState(() {
        _pageWidgets = _pages
            .map((p) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      p.image,
                      const ListSpacer(height: 15),
                      Center(
                          child: Text(p.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1!
                                  .copyWith(fontSize: 24))),
                      const ListSpacer(height: 15),
                      Center(
                          child: Text(p.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontSize: 18.0))),
                    ]))
            .toList();
      });
    });
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
                minimumSize: const Size.fromHeight(56)),
            onPressed: () => widget.onComplete(),
            child: const Text("Get Started"))
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
                child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(25),
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
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              padding:
                                  const EdgeInsets.only(top: 40, right: 25),
                              child: _buildButton())),
                      // Align(
                      //     alignment: Alignment.bottomCenter,
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: _pages.asMap().entries.map((entry) {
                      //         return Container(
                      //             width: 12.0,
                      //             height: 12.0,
                      //             margin: const EdgeInsets.symmetric(
                      //                 vertical: 20.0, horizontal: 4.0),
                      //             decoration: BoxDecoration(
                      //                 shape: BoxShape.circle,
                      //                 color: Colors.black.withOpacity(
                      //                     _current == entry.key ? 0.9 : 0.4)));
                      //       }).toList(),
                      //     )),
                    ])))));
  }
}
