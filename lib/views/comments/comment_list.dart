import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/components/loading.dart';
import 'package:sagelink_communities/models/comment_model.dart';
import 'package:sagelink_communities/views/comments/comment_cell.dart';
import 'package:flutter/material.dart';

typedef ShowThreadCallback = void Function(String commentId);

typedef AddReplyCallback = void Function(String commentId);

typedef AddReactionCallback = void Function(String commentId);

typedef ReloadCommentsCallback = void Function();
typedef CloseThreadCallback = void Function();

String getCommentThreadQuery = """
query GetCommentThreadQuery(\$where: CommentWhere, \$options: CommentOptions) {
  comments(where: \$where, options: \$options) {
    replies {
      id
      body
      createdAt
      createdBy {
        id
        name
      }
    }
    repliesAggregate {
      count
    }
    id
    body
    createdAt
    createdBy {
      id
      name
    }
  }
}
""";

class CommentListView extends StatefulWidget {
  final List<CommentModel> comments;

  final ShowThreadCallback? onShowThread;
  final CloseThreadCallback? onCloseThread;
  final AddReplyCallback? onAddReply;
  final AddReactionCallback? onAddReaction;
  final ReloadCommentsCallback? shouldReloadComments;
  final bool shrinkWrap;

  const CommentListView(this.comments,
      {this.shouldReloadComments,
      this.onShowThread,
      this.onCloseThread,
      this.onAddReply,
      this.onAddReaction,
      this.shrinkWrap = false,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  List<CommentModel> showingComments = [];
  List<CommentModel> initialComments = [];

  bool showingThread = false;
  bool fetching = false;

  @override
  void initState() {
    super.initState();
    initialComments = widget.comments;
    showingComments = initialComments;
  }

  void closeThread(bool shouldReload) {
    if (widget.onCloseThread != null) {
      widget.onCloseThread!();
    }
    if (shouldReload && widget.shouldReloadComments != null) {
      widget.shouldReloadComments!();
    }
    setState(() {
      fetching = false;
      showingThread = false;
      showingComments = initialComments;
    });
  }

  void shouldShowThread(GraphQLClient client, BuildContext context,
      CommentModel parentComment) async {
    setState(() {
      fetching = true;
    });
    if (widget.onShowThread != null) {
      widget.onShowThread!(parentComment.id);
    }
    var updatedComments = await _fetchThread(client, parentComment);
    setState(() {
      fetching = false;
      showingThread = true;
      showingComments = updatedComments;
    });
  }

  Future<List<CommentModel>> _fetchThread(
      GraphQLClient client, CommentModel parent) async {
    Map<String, dynamic> variables = {
      "where": {"id": parent.id},
      "options": {
        "sort": [
          {"createdAt": "DESC"}
        ]
      }
    };

    QueryResult result = await client.query(QueryOptions(
      document: gql(getCommentThreadQuery),
      variables: variables,
    ));

    if (result.data != null && (result.data!['comments'] as List).isNotEmpty) {
      List commentJsons = result.data!['comments'][0]['replies'] as List;
      return [
        parent,
        ...commentJsons.map((e) => CommentModel.fromJson(e)).toList()
      ];
    }
    return [];
  }

  Widget _buildCommentList(BuildContext context, GraphQLClient client) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: showingComments.length,
      cacheExtent: 20,
      controller: ScrollController(),
      itemBuilder: (context, index) => CommentCell(
        index,
        showingComments[index],
        inThreadView: showingThread,
        onAddReply: widget.onAddReply,
        onShowThread: (commentId) =>
            shouldShowThread(client, context, showingComments[index]),
        onAddReaction: widget.onAddReaction,
      ),
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget _buildHeader() {
    return showingThread
        ? (Align(
            alignment: Alignment.topLeft,
            child: IconButton(
                onPressed: () => closeThread(true),
                icon: const Icon(Icons.close))))
        : (const SizedBox.shrink());
  }

  @override
  Widget build(BuildContext context) {
    if (fetching) {
      return const Loading();
    }

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [_buildHeader(), _buildCommentList(context, client)],
      );
    });
  }
}
