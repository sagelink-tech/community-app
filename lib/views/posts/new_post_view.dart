import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:community_app/providers.dart';

String createPostMutation = """
mutation CreatePosts(\$input: [PostCreateInput!]!) {
  createPosts(input: \$input) {
    info {
      nodesCreated
    }
  }
}
""";

typedef OnCompletionCallback = void Function();

class NewPostPage extends ConsumerStatefulWidget {
  const NewPostPage(
      {Key? key, required this.brandId, required this.onCompleted})
      : super(key: key);
  final String brandId;
  final OnCompletionCallback onCompleted;

  static const routeName = '/posts';

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends ConsumerState<NewPostPage> {
  final formKey = GlobalKey<FormState>();
  String? title;
  String? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        actions: [
          buildSubmit(
              enabled: (title != null &&
                  title!.isNotEmpty &&
                  body != null &&
                  body!.isNotEmpty)),
        ],
      ),
      body: Form(
          key: formKey,
          //autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildTitleForm(),
              const SizedBox(height: 16),
              buildBodyForm()
            ],
          )),
    );
  }

  Widget buildTitleForm({bool enabled = true}) => TextFormField(
        decoration: const InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          errorStyle: TextStyle(color: Colors.purple),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          } else {
            return null;
          }
        },
        maxLength: 150,
        onChanged: (value) => setState(() => title = value),
        enabled: enabled,
      );

  Widget buildBodyForm({bool enabled = true}) => TextFormField(
      decoration: const InputDecoration(
        labelText: 'Body',
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
      minLines: 15,
      maxLines: 15,
      onChanged: (value) => setState(() => body = value),
      enabled: enabled);

  Widget buildSubmit({bool enabled = true}) => Builder(
      builder: (context) => Mutation(
          options: MutationOptions(
              document: gql(createPostMutation),
              onCompleted: (dynamic resultData) {
                widget.onCompleted();
                Navigator.pop(context);
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
                                "title": title,
                                "body": body,
                                "inBrandCommunity": {
                                  "connect": {
                                    "where": {
                                      "node": {"id": widget.brandId}
                                    }
                                  }
                                },
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
                                }
                              }
                            ]
                          });
                        }
                      }
                    : null,
              )));
}
