import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/ui/components/clickable_avatar.dart';
import 'package:sagelink_communities/ui/components/feedback_form.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/views/users/account_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final _user =
      ref.watch(loggedInUserProvider.select((value) => value.getUser()));
  late final auth = ref.watch(authProvider);

  void _goToAccount() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AccountPage(userId: _user.id)));
  }

  void _goToNotifications() {
    print("GO TO NOTIFICATIONS");
  }

  void _goToDataSettings() {
    print("GO TO DATA SETTINGS");
  }

  void _goToPrivacy() {
    print("Go TO PRIVACY");
  }

  void _goToTerms() {
    print("Go TO TERMS");
  }

  void _dismissFeedbackForm(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showFeedbackForm() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => FeedbackForm(
            onSubmit: () => _dismissFeedbackForm(context),
            onCancel: () => _dismissFeedbackForm(context)));
  }

  _buildMainSelection() {
    List<Widget> items = [
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(
            "Account settings",
            style: Theme.of(context).textTheme.headline3,
          )),
      ListTile(
        leading: ClickableAvatar(
            avatarText: _user.name,
            avatarImage: _user.profileImage(),
            radius: 15),
        title: const Text("My profile"),
        onTap: _goToAccount,
      ),
      ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text("Notifications"),
        onTap: _goToNotifications,
      ),
      ListTile(
        leading: const Icon(Icons.bar_chart_outlined),
        title: const Text("Data preferences"),
        onTap: _goToDataSettings,
      ),
      ListTile(
        leading: const Icon(Icons.message_outlined),
        title: const Text("Feedback & Support"),
        onTap: _showFeedbackForm,
      ),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Legal",
            style: Theme.of(context).textTheme.headline5,
          )),
      ListTile(
        leading: const Icon(Icons.privacy_tip_outlined),
        title: const Text("Privacy policy"),
        onTap: _goToPrivacy,
      ),
      ListTile(
        leading: const Icon(Icons.grading_outlined),
        title: const Text("Terms and conditions"),
        onTap: _goToTerms,
      )
    ];
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => items[index],
        separatorBuilder: (BuildContext context, int index) =>
            index > 0 ? const Divider() : const ListSpacer(height: 1),
        itemCount: items.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(""),
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 1,
        ),
        body: Stack(alignment: Alignment.bottomCenter, children: [
          _buildMainSelection(),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  color: Theme.of(context).backgroundColor,
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.secondary,
                          minimumSize: const Size.fromHeight(48)),
                      onPressed: () => {
                            auth.signOut(),
                            Navigator.popUntil(context,
                                (Route<dynamic> route) => route.isFirst)
                          },
                      child: const Text("Sign out")))),
        ]));
  }
}
