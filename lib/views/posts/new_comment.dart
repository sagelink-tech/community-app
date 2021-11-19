import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:community_app/providers.dart';

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
  const NewComment({Key? key, required this.postId, required this.onCompleted})
      : super(key: key);
  final String postId;
  final OnCompletionCallback onCompleted;

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
            Expanded(child: buildBodyForm()),
            buildSubmit(enabled: body != null && body!.isNotEmpty)
          ],
        ));
  }

  Widget buildBodyForm({bool enabled = true}) => TextFormField(
      decoration: const InputDecoration(
        labelText: 'Comment',
        border: OutlineInputBorder(),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
        focusedErrorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
        errorStyle: TextStyle(color: Colors.purple),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter body text';
        } else {
          return null;
        }
      },
      maxLength: 2000,
      onChanged: (value) => setState(() => body = value),
      enabled: enabled);

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
                          runMutation({
                            "input": [
                              {
                                "body": body,
                                "createdBy": {
                                  "connect": {
                                    "where": {
                                      "node": {
                                        "id": ref
                                            .read(loggedInUserProvider)
                                            .userId
                                      }
                                    }
                                  }
                                },
                                "onPost": {
                                  "connect": {
                                    "where": {
                                      "node": {"id": widget.postId}
                                    }
                                  }
                                }
                              }
                            ]
                          });
                        }
                      }
                    : null,
              )));
}
