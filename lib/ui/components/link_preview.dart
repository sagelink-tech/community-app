import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/empty_result.dart';

class LinkPreview extends StatelessWidget {
  final String? linkUrl;
  final bool showError;

  LinkPreview(this.linkUrl, {this.showError = false, Key? key})
      : super(key: key);

  late final bool _validUrl =
      linkUrl != null && AnyLinkPreview.isValidLink(linkUrl!);

  _buildPreview(BuildContext context) {
    return AnyLinkPreview(
      link: linkUrl!,
      proxyUrl: kIsWeb
          ? "https://us-central1-sagelink-community.cloudfunctions.net/proxyWithCorsAnywhere/"
          : null,
      displayDirection: uiDirection.uiDirectionHorizontal,
      backgroundColor: Theme.of(context).cardColor,
      titleStyle: Theme.of(context).textTheme.headline6,
      bodyStyle: Theme.of(context).textTheme.caption,
      bodyMaxLines: 3,
      removeElevation: true,
      borderRadius: 5,
      bodyTextOverflow: TextOverflow.fade,
      errorTitle: "Invalid URL",
      errorBody:
          "The url you've entered cannot be previewed. Please check the url.",
    );
  }

  _buildError(BuildContext context) {
    return EmptyResult(text: "Could not load preview for: " + linkUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        //
        //height: 72,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            border: Border.all(
                color: _validUrl || showError
                    ? Theme.of(context).dividerColor
                    : Colors.transparent)),
        child: _validUrl
            ? _buildPreview(context)
            : showError
                ? _buildError(context)
                : null);
  }
}
