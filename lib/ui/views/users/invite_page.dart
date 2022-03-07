import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/invite_model.dart';
import 'package:sagelink_communities/ui/components/custom_widgets.dart';
import 'package:sagelink_communities/ui/components/list_spacer.dart';
import 'package:sagelink_communities/data/providers.dart';
import 'package:sagelink_communities/ui/components/loading.dart';

enum InviteType { members, teammates }

const customerInputHint =
    'Enter email, id, and tier for each invitee on a new line:\n\nemail_1, customer_id_1, tier_1\nemail_2, customer_id_2, tier_2\n...';
const employeeInputHint =
    'Enter email, job title, [true or false] for founder, and [true or false] for owner for each invitee on a new line:\n\nemail_1, jobtitle_1, owner_tf_1, founder_tf_1\nemail_2, jobtitle_2, owner_tf_2, founder_tf_2\n...';

class InvitePage extends ConsumerStatefulWidget {
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final InviteType inviteType;

  const InvitePage(
      {this.onSubmit, this.onCancel, required this.inviteType, Key? key})
      : super(key: key);

  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends ConsumerState<InvitePage> {
  bool _isInviting = false;
  String? inviteData;

  late final userService = ref.watch(userServiceProvider);
  late final brandId =
      ref.watch(loggedInUserProvider.select((value) => value.adminBrandId));

  parseInviteData() {
    if (inviteData == null || inviteData!.isEmpty) {
      CustomWidgets.buildSnackBar(
          context, "No input data detected..", SLSnackBarType.error);
      return [];
    }
    List<String> rows = inviteData!.trim().split('\n');
    List<InviteModel> invites = [];
    switch (widget.inviteType) {
      case InviteType.members:
        for (int i = 0; i < rows.length; i++) {
          final data = rows[i].trim().split(',');
          if (data.length != 3) {
            CustomWidgets.buildSnackBar(
                context,
                "Error parsing input data at line $i. Expected 3 comma separated variables but got ${data.length}",
                SLSnackBarType.error);

            return [];
          }
          invites.add(MemberInviteModel(
              id: "id",
              userEmail: data[0].replaceAll(' ', ''),
              isAdmin: false,
              brandId: brandId,
              customerId: data[1].replaceAll(' ', ''),
              memberTier: data[2].trim()));
        }
        return List<MemberInviteModel>.from(invites);
      case InviteType.teammates:
        for (int i = 0; i < rows.length; i++) {
          final data = rows[i].trim().split(',');
          if (data.length != 4) {
            CustomWidgets.buildSnackBar(
                context,
                "Error parsing input data at line $i. Expected 4 comma separated variables but got ${data.length}",
                SLSnackBarType.error);

            return [];
          }
          invites.add(EmployeeInviteModel(
              id: "id",
              userEmail: data[0].replaceAll(' ', ''),
              isAdmin: true,
              brandId: brandId,
              jobTitle: data[1].trim(),
              roles: ['admin'],
              owner: data[2].toLowerCase() == "true",
              founder: data[3].toLowerCase() == "true"));
        }
        return List<EmployeeInviteModel>.from(invites);
    }
  }

  void onSuccess() {
    if (widget.onSubmit != null) {
      widget.onSubmit!();
    }
    CustomWidgets.buildSnackBar(
        context, "Successfully created invites!", SLSnackBarType.success);

    Navigator.of(context).pop();
  }

  void inviteUsers() async {
    setState(() {
      _isInviting = true;
    });
    List<MemberInviteModel> invites = parseInviteData();
    if (invites.isNotEmpty) {
      bool success = await userService.inviteUsersToCommunity(invites);
      if (success) {
        onSuccess();
      }
    }
    setState(() {
      _isInviting = false;
    });
  }

  void inviteTeammates() async {
    setState(() {
      _isInviting = true;
    });
    List<EmployeeInviteModel> invites =
        parseInviteData() as List<EmployeeInviteModel>;
    if (invites.isNotEmpty) {
      bool success = await userService.inviteUsersToTeam(invites);
      if (success) {
        onSuccess();
      }
    }
    setState(() {
      _isInviting = false;
    });
  }

  Widget _buildInputForm({bool enabled = true}) => TextFormField(
        key: const Key("invite_input"),
        decoration: InputDecoration(
          hintText: widget.inviteType == InviteType.members
              ? customerInputHint
              : employeeInputHint,
          border: const OutlineInputBorder(),
        ),
        minLines: 10,
        maxLines: 10,
        initialValue: inviteData,
        onChanged: (value) => setState(() => inviteData = value),
        enabled: enabled,
      );

  Widget fullForm() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _buildInputForm(),
          const ListSpacer(height: 20),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                  onPrimary: Theme.of(context).colorScheme.onError,
                  minimumSize: const Size.fromHeight(48)),
              onPressed: inviteData != null && inviteData!.isNotEmpty
                  ? () => widget.inviteType == InviteType.members
                      ? inviteUsers()
                      : inviteTeammates()
                  : null,
              child: const Text("Create Invite Codes")),
          const ListSpacer(height: 20),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onCancel != null) {
                  widget.onCancel!();
                }
              },
              child: const Text("Cancel"))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).backgroundColor,
          automaticallyImplyLeading: false,
          title: Text("Invite " +
              (widget.inviteType == InviteType.members
                  ? "Members"
                  : "Teammates")),
        ),
        body: _isInviting ? const Loading() : fullForm());
  }
}
