import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/providers.dart';

String createCommentMutation = """
mutation CreateComments(\$input: [CommentCreateInput!]!) {
  createComments(input: \$input) {
    info {
      nodesCreated
    }
  }
}
""";

typedef OnCompletionCallback = void Function();

class NewComment extends ConsumerStatefulWidget {
  const NewComment(
      {Key? key,
      required this.parentId,
      required this.onCompleted,
      this.focused = false,
      this.isOnPerk = false,
      this.isReply = false})
      : super(key: key);

  final String parentId;
  final OnCompletionCallback onCompleted;
  final bool focused;
  final bool isReply;
  final bool isOnPerk;

  static const routeName = '/comments';

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends ConsumerState<NewComment> {
  final formKey = GlobalKey<FormState>();
  String? body;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        //autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Row(
          children: [
            Expanded(child: buildBodyForm(context)),
            buildSubmit(enabled: body != null && body!.isNotEmpty)
          ],
        ));
  }

  Widget buildBodyForm(BuildContext context, {bool enabled = true}) =>
      Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          color: Theme.of(context).canvasColor,
          child: TextFormField(
              autofocus: widget.focused,
              decoration: InputDecoration(
                labelText: 'Comment',
                border: const OutlineInputBorder(),
                errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).errorColor)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).errorColor)),
                errorStyle: TextStyle(color: Theme.of(context).errorColor),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter body text';
                } else {
                  return null;
                }
              },
              minLines: 1,
              maxLines: 1,
              onChanged: (value) => setState(() => body = value),
              enabled: enabled));

  _getCommentVariables() {
    var input = {
      "body": body,
      "createdBy": {
        "connect": {
          "where": {
            "node": {"id": ref.read(loggedInUserProvider).getUser().id}
          }
        }
      }
    };
    var connectionData = {
      "connect": {
        "where": {
          "node": {"id": widget.parentId}
        }
      }
    };

    if (widget.isReply) {
      input["onComment"] = connectionData;
    } else if (widget.isOnPerk) {
      input["onPerk"] = connectionData;
    } else {
      input["onPost"] = connectionData;
    }
    return {
      "input": [input]
    };
  }

  Widget buildSubmit({bool enabled = true}) => Builder(
      builder: (context) => Mutation(
          options: MutationOptions(
              document: gql(createCommentMutation),
              onCompleted: (dynamic resultData) {
                widget.onCompleted();
              }),
          builder: (RunMutation runMutation, result) => IconButton(
                icon: const Icon(Icons.send),
                onPressed: enabled
                    ? () {
                        if (formKey.currentState == null) return;
                        final isValid = formKey.currentState!.validate();

                        if (isValid) {
                          runMutation(_getCommentVariables());
                        }
                      }
                    : null,
              )));
}
