import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:sagelink_communities/data/providers.dart';

class GoToAdminPage extends ConsumerWidget {
  const GoToAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider.notifier);

    return Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appState.status.isViewingAdminSite
                  ? ("Would you like to transfer to the Main Site?")
                  : ("Would you like to transfer to the Admin Site?"),
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.secondary,
                    onPrimary: Theme.of(context).colorScheme.onError),
                onPressed: () => {
                      appState.setViewingAdminSite(
                          !appState.status.isViewingAdminSite)
                    },
                child: const Text("Confirm"))
          ],
        ));
  }
}
