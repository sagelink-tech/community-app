import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/services/user_service.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:sagelink_communities/ui/components/feedback_form.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/views/pages/settings_page.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';

class AcceptInvitePage extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final bool showFullDetails;

  const AcceptInvitePage(
      {required this.onComplete, this.showFullDetails = false, Key? key})
      : super(key: key);

  @override
  _AcceptInvitePageeState createState() => _AcceptInvitePageeState();
}

class _AcceptInvitePageeState extends ConsumerState<AcceptInvitePage> {
  final formKey = GlobalKey<FormState>();
  String? inviteCode;
  bool isLoading = false;
  late final UserService userService = ref.watch(userServiceProvider);
  late final LoggedInUser loggedInUser = ref.watch(loggedInUserProvider);

  void _handleRefresh() {
    ref.refresh(loggedInUserProvider);
  }

  void _handleSubmit() async {
    if (inviteCode == null) {
      return;
    }
    bool success = await userService.acceptInvitationWithCode(inviteCode!);
    if (success) {
      CustomWidgets.buildSnackBar(
          context, "Check your email to verify", SLSnackBarType.success);

      widget.onComplete();
    } else {
      CustomWidgets.buildSnackBar(context,
          "There was an error with this invite code", SLSnackBarType.error);
    }
  }

  List<Widget> _fullDetails() {
    return widget.showFullDetails
        ? [
            Text("Enter an invite code to join your first community!",
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center),
            const ListSpacer(height: 20),
            ..._formWidgets(),
            const ListSpacer(height: 20),
            const Divider(),
            const ListSpacer(height: 20),
            Text("Don't have one? In the meantime, you can do the following:",
                style: Theme.of(context).textTheme.bodyText2),
            const ListSpacer(height: 20),
            OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () => _goToAccount(loggedInUser.getUser().id),
                icon: ClickableAvatar(
                    radius: 15,
                    avatarText: loggedInUser.getUser().name[0],
                    avatarImage: loggedInUser.getUser().profileImage()),
                label: const Text("View account")),
            const ListSpacer(height: 20),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () => _goToSettings(),
                child: const Text("View settings")),
            const ListSpacer(height: 20),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () => _showFeedbackForm(),
                child: const Text("Send feedback")),
          ]
        : _formWidgets();
  }

  List<Widget> _formWidgets() => [
        _buildEntryForm(),
        const ListSpacer(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                onPrimary: Theme.of(context).colorScheme.onError,
                minimumSize: const Size.fromHeight(48)),
            onPressed: (inviteCode == null || inviteCode!.length != 6)
                ? null
                : () => _handleSubmit(),
            child: const Text("Submit")),
      ];

  void _goToAccount(String userId) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => FractionallySizedBox(
            heightFactor: 0.85, child: AccountPage(userId: userId)));
  }

  void _goToSettings() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => const FractionallySizedBox(
            heightFactor: 0.85, child: SettingsPage()));
  }

  void _dismissFeedbackForm(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showFeedbackForm() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => FractionallySizedBox(
            heightFactor: 0.85,
            child: FeedbackForm(
                onSubmit: () => _dismissFeedbackForm(context),
                onCancel: () => _dismissFeedbackForm(context))));
  }

  Widget _buildEntryForm({bool enabled = true}) => TextFormField(
        keyboardType: TextInputType.text,
        maxLength: 6,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]{0,6}')),
        ],
        decoration: const InputDecoration(
            counterText: "",
            hintText: 'Enter your invite code',
            border: OutlineInputBorder()),
        onChanged: (value) => setState(() => inviteCode = value),
        enabled: enabled,
      );

  @override
  Widget build(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).backgroundColor,
            title: const Text("Invite code"),
            elevation: 0,
            actions: widget.showFullDetails
                ? [
                    IconButton(
                      icon: const Icon(Icons.refresh_outlined),
                      onPressed: _handleRefresh,
                    ),
                  ]
                : [],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: isLoading
                ? const CircularProgressIndicator()
                : ListView(children: _fullDetails()),
          ));
    });
  }
}
