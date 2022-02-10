import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/data/services/user_service.dart';

class AcceptInvitePage extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const AcceptInvitePage({required this.onComplete, Key? key})
      : super(key: key);

  @override
  _AcceptInvitePageeState createState() => _AcceptInvitePageeState();
}

class _AcceptInvitePageeState extends ConsumerState<AcceptInvitePage> {
  final formKey = GlobalKey<FormState>();
  String? inviteCode;
  bool isLoading = false;
  late final UserService userService = ref.watch(userServiceProvider);

  void _handleSubmit() async {
    if (inviteCode == null) {
      return;
    }
    bool success = await userService.acceptInvitationWithCode(inviteCode!);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text("Check your email to verify"),
        backgroundColor: Theme.of(context).primaryColor,
      ));
      widget.onComplete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("There was an error with this invite code"),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
  }

  Widget _buildEntryForm({bool enabled = true}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextFormField(
        decoration: const InputDecoration(
            labelText: 'Invite code', border: OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an email';
          } else {
            return null;
          }
        },
        onChanged: (value) => setState(() => inviteCode = value),
        enabled: enabled,
      ));

  @override
  Widget build(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
          body: Container(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    _buildEntryForm(),
                    ElevatedButton(
                        onPressed: () => _handleSubmit(),
                        child: const Text("Submit")),
                  ]),
      ));
    });
  }
}
