import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/task_service.dart';

class CommentSection extends StatefulWidget {
  final String taskId;

  const CommentSection({required this.taskId, super.key});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  List<dynamic> _comments = [];
  final _newCommentController = TextEditingController();
  String? _replyingToCommentId;
  final _replyController = TextEditingController();
  User? currentUser;
  Set<String> _openedReplies = {};

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    currentUser = await AuthService().getCurrentUser();
    setState(() {});
  }

  Future<void> _loadComments() async {
    final comments = await TaskService().getTaskComments(widget.taskId);
    setState(() {
      _comments = comments;
    });
  }

  Future<void> _addComment() async {
    final text = _newCommentController.text.trim();
    if (text.isEmpty) return;

    await TaskService().postComment(widget.taskId, text);
    _newCommentController.clear();
    _loadComments();
  }

  Future<void> _submitReply(String commentId) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    await TaskService().postReply(widget.taskId, commentId, text);
    _replyController.clear();
    _replyingToCommentId = null;
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          // Comment List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return _buildCommentTile(comment);
            },
          ),

          // Divider(),

          // New Comment Box
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCommentController,
                  decoration: InputDecoration(hintText: 'Write a comment...'),
                ),
              ),
              IconButton(icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary,), onPressed: _addComment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
            leading: FutureBuilder<User>(
              future: AuthService().getUserProfile(comment['user']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircleAvatar(child: Icon(Icons.person));
                }
                final user = snapshot.data!;
                return (user.profilePhoto != null &&
                        user.profilePhoto!.isNotEmpty)
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePhoto!),
                      radius: 20,
                    )
                    : user.buildAvatar(radius: 16);
              },
            ),
            title: FutureBuilder<User>(
              future: AuthService().getUserProfile(comment['user']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text('Loading...');
                final user = snapshot.data!;
                return Row(
                  children: [
                    Expanded(
                      child:
                          user.id != currentUser!.id
                              ? Text(
                                user.name,
                                style: TextStyle(fontWeight: FontWeight.bold, color:Theme.of(context).colorScheme.secondary,),
                              )
                              : Text(
                                'You',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                    ),
                  ],
                );
              },
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 4),
                Text(
                  comment['text'],
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                // SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 4),
                        // padding: EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        iconColor: Colors.blueGrey,
                        foregroundColor: Colors.blueGrey,
                        // backgroundColor: Colors.grey
                      ),
                      label: Text('Reply', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.reply_all_rounded),
                      onPressed: () {
                        setState(() {
                          if (_openedReplies.contains(comment['_id'])) {
                            _openedReplies.remove(comment['_id']);
                          } else {
                            _openedReplies.add(comment['_id']);
                          }
                          
                          _replyingToCommentId =
                              _replyingToCommentId == comment['_id']
                                  ? null
                                  : comment['_id'];
                        });
                      },
                    ),
                    if ((comment['replies'] as List).isNotEmpty)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 4),
                        // padding: EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        iconColor: Colors.blueGrey,
                        foregroundColor: Colors.blueGrey,
                        // backgroundColor: Colors.grey
                      ),
                      label: Text(
                        _openedReplies.contains(comment['_id'])
                            ? 'Hide all reply'
                            : 'Show all reply',
                        style: TextStyle(fontSize: 12),
                      ),
                      // icon: Icon(Icons.reply_all_rounded),
                      onPressed: () {
                        setState(() {
                          if (_openedReplies.contains(comment['_id'])) {
                            _openedReplies.remove(comment['_id']);
                          } else {
                            _openedReplies.add(comment['_id']);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            // trailing:
          ),
        ),
        Divider(),
        if (_openedReplies.contains(comment['_id']))

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                // Replies
                ...comment['replies'].map<Widget>(
                  (reply) => _buildReplyTile(reply),
                ),

                // Reply input
                if (_replyingToCommentId == comment['_id'])
                  _buildReplyInput(comment['_id']),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReplyTile(Map<String, dynamic> reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, top: 8),
      child: FutureBuilder<User>(
        future: AuthService().getUserProfile(reply['user']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          final replyUser = snapshot.data!;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (replyUser.profilePhoto != null &&
                      replyUser.profilePhoto!.isNotEmpty)
                  ? CircleAvatar(
                    backgroundImage: NetworkImage(replyUser.profilePhoto!),
                    radius: 12,
                  )
                  : replyUser.buildAvatar(radius: 12),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            replyUser.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        if (replyUser.id == currentUser?.id)
                          Text(
                            ' (You)',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    Text(reply['text'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReplyInput(String commentId) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                // fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => _submitReply(commentId),
            ),
          ),
        ],
      ),
    );
  }
}
