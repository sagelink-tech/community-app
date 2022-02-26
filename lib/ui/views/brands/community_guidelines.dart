import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CommunityGuidelines extends StatelessWidget {
  final String guidelineText;

  const CommunityGuidelines({required this.guidelineText, Key? key})
      : super(key: key);

  Future<void> _launchURL(String? url) async {
    if (url == null) {
      return;
    }
    try {
      !await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(15),
        child: ListView(shrinkWrap: true, children: [
          Text(
            "Guidelines",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline3,
          ),
          const ListSpacer(height: 20),
          MarkdownBody(
            data: guidelineText,
            onTapLink: (String text, String? href, String title) =>
                _launchURL(href),
          )
        ]));
  }
}
