// Dummy Comment model for now
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Comment {
  final String userName;
  final String content;
  final List<String> replies;
  bool isExpanded;

  Comment({
    required this.userName,
    required this.content,
    this.replies = const [],
    this.isExpanded = false,
  });
}

// Your Comments List (normally from backend)
List<Comment> comments = [
  Comment(userName: 'User A', content: 'Is this task remote?', replies: ['Yes, it is remote.']),
  Comment(userName: 'User B', content: 'Can you explain budget details?', replies: ['The budget is flexible.']),
  Comment(userName: 'User C', content: 'What is the expected timeline?'),
];

// Inside your TaskDetailBody under Comments Section:


// Comment Input Field
// SizedBox(height: 20),
// TextField(
//   decoration: InputDecoration(
//     hintText: 'Ask a question or leave a comment...',
//     filled: true,
//     fillColor: Colors.grey.shade100,
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(12),
//       borderSide: BorderSide.none,
//     ),
//     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     suffixIcon: IconButton(
//       icon: Icon(Icons.send),
//       onPressed: () {
//         // TODO: Add comment logic
//       },
//     ),
//   ),
// ),
// SizedBox(height: 100),
