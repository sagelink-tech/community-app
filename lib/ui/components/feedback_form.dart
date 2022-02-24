import 'package:flutter/material.dart';
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
              'Share some feedback...\n\nWhat brands do you love?\nWhat interests and causes do you care about?\nWhat brought you to Sagelink?',
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: success
          ? const Text("Successful!")
          : const Text("Error launching mail app"),
      backgroundColor:
          success ? Colors.greenAccent : Theme.of(context).colorScheme.error,
    ));
    if (widget.onSubmit != null) {
      widget.onSubmit!();
    }
  }

  List<Widget> _feedbackWidgets() => [
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
            child: const Text("Send Feedback")),
        const ListSpacer(height: 20),
        OutlinedButton(
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel!();
              }
            },
            child: const Text("Cancel")),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      child: isSaving
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min, children: _feedbackWidgets()),
    );
  }
}
