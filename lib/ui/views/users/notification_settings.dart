import 'package:sagelink_communities/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/services/user_service.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/ui/components/loading.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  static const routeName = '/notifications';

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  late final messager = ref.watch(messagingProvider);
  late final userService = ref.watch(userServiceProvider);

  bool _isLoading = false;

  List<Map<String, List<NotificationSetting>>> settings = [];

  _fetchSettings() async {
    setState(() {
      _isLoading = true;
    });
    var settingsResult = await userService.fetchNotificationSettings();
    setState(() {
      _isLoading = false;
      settings = settingsResult;
    });
  }

  _handleToggle(bool value, NotificationSetting setting) async {
    setState(() {
      _isLoading = true;
    });

    bool result = await messager.setTopicSubscriptionStatus(
        value, setting.topic,
        forBrandId: setting.brand != null ? setting.brand!.id : null);
    if (result) {
      _fetchSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _fetchSettings();
    });
  }

  _buildSettingsList() {
    List<Widget> items = [];
    for (var brandSetting in settings) {
      items.addAll([
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              brandSetting.keys.first,
              style: Theme.of(context).textTheme.headline4,
            )),
        ...brandSetting.values.first
            .map((e) => SwitchListTile(
                title: Text(e.title),
                value: e.status,
                onChanged: (value) => _handleToggle(value, e)))
            .toList()
      ]);
    }

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
        body: _isLoading ? const Loading() : _buildSettingsList());
  }
}
