import 'package:flutter/material.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackForm extends StatefulWidget {
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  const FeedbackForm({this.onSubmit, this.onCancel, Key? key})
      : super(key: key);

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final formKey = GlobalKey<FormState>();
  String? feedbackText;
  bool isSaving = false;

  Widget buildFeedbackForm({bool enabled = true}) => TextFormField(
        autofocus: true,
        key: const Key("feedback_key"),
        decoration: const InputDecoration(
          hintText:
              "What made you interested in joining? What brands would you like to see in this app?",
          border: OutlineInputBorder(),
        ),
        minLines: 7,
        maxLines: 7,
        initialValue: feedbackText,
        onChanged: (value) => setState(() => feedbackText = value),
        enabled: enabled,
      );

  void _submitFeedback() async {
    final Uri _emailLaunchUri =
        Uri(scheme: 'mailto', path: 'support@sage.link', queryParameters: {
      "subject": "Future User - Feedback",
      "body": feedbackText,
    });
    bool success = await launch(_emailLaunchUri.toString());
    CustomWidgets.buildSnackBar(
        context,
        success ? "Successful!" : "Error launching mail app",
        success ? SLSnackBarType.success : SLSnackBarType.error);
    if (widget.onSubmit != null) {
      widget.onSubmit!();
    }
  }

  List<Widget> _feedbackWidgets() => [
        Row(
          children: [
            const Spacer(),
            IconButton(
                icon: Icon(Icons.close_outlined),
                onPressed: () {
                  if (widget.onCancel != null) {
                    widget.onCancel!();
                  }
                })
          ],
        ),
        const ListSpacer(height: 20),
        buildFeedbackForm(),
        const ListSpacer(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                onPrimary: Theme.of(context).colorScheme.onError,
                minimumSize: const Size.fromHeight(48)),
            onPressed: feedbackText != null && feedbackText!.isNotEmpty
                ? () => _submitFeedback()
                : null,
            child: const Text("Send feedback as email")),
        const ListSpacer(height: 20),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: isSaving
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min, children: _feedbackWidgets()),
    );
  }
}
