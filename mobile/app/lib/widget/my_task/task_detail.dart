import 'dart:convert';
import 'package:app/model/bid.dart';
import 'package:app/model/task.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/chat_screen.dart';
import 'package:app/widget/my_task/bids.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyTaskDetails extends StatelessWidget {
  final String taskId;

  MyTaskDetails({required this.taskId});

  final formatter = DateFormat.yMMMMd();

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    final user = jsonDecode(userJson);
    return user['_id'] ?? user['id'];
  }

  void showBidsModal({
    required BuildContext context,
    required List<Bid> bids,
    required String taskId,
    required VoidCallback onBidAccepted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.9;
        return Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('All Bids', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: bids.length,
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    return _buildBidCard(context, bid, taskId, onBidAccepted);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBidCard(
    BuildContext context,
    Bid bid,
    String taskId,
    VoidCallback onBidAccepted,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bid by: ${bid.provider}'),
          Text('Price: \$${bid.price}'),
          Text('Estimated Time: ${bid.estimatedTime}'),
          Text('Bid made: ${timeago.format(bid.date)}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: Text('View Profile')),
              TextButton(
                onPressed: () {
                  TaskService().acceptBid(taskId, bid.id).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bid accepted successfully!')),
                    );
                    Navigator.pop(context);
                    onBidAccepted();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to accept bid: $error')),
                    );
                  });
                },
                child: Text('Accept Offer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Details'), elevation: 2),
      body: FutureBuilder<Task>(
        future: TaskService().getTask(taskId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final task = snapshot.data!;
          final user = task.user;

          return FutureBuilder<String?>(
            future: _getCurrentUserId(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return Center(child: CircularProgressIndicator());
              final currentUserId = userSnapshot.data;
              final isPoster = currentUserId == task.user.id;
              final isCompleted = task.status.toLowerCase() == 'completed';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ${task.status}',
                          style: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(task.status.toUpperCase(),
                            style: GoogleFonts.figtree(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _getStatusProgress(task.status),
                      backgroundColor: Colors.grey.shade300,
                      color: _getStatusColor(task.status),
                      minHeight: 6,
                    ),
                    SizedBox(height: 24),

                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.title, style: GoogleFonts.figtree(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            Text(task.description, style: GoogleFonts.figtree(fontSize: 15)),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.attach_money, color: Colors.green, size: 20),
                                SizedBox(width: 6),
                                Text('Budget: \$${task.budget.toStringAsFixed(2)}'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18),
                                SizedBox(width: 6),
                                Text('Deadline: ${formatter.format(task.deadline)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    Text('Posted by', style: GoogleFonts.figtree(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            user.buildAvatar(radius: 28),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16, color: Color(0xFFFFB700)),
                                      SizedBox(width: 4),
                                      Text(user.rating?.toStringAsFixed(1) ?? 'No reviews yet',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(user.email, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // ✅ Assigned Provider Section + Chat Button
                    if (task.assignedProvider != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, color: Colors.teal),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('This task is assigned to:',
                                style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.teal.shade100,
                                child: Text('ID', style: TextStyle(color: Colors.white)),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.assignedProvider ?? 'Unknown',
                                        style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text('Email not loaded', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('Rating not available', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.chat_bubble_outline),
                        label: Text("Open Chat"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                taskId: task.id,
                                userId: currentUserId!,
                              ),
                            ),
                          );
                        },
                      ),
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  double _getStatusProgress(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return 1.0;
      case 'in progress': return 0.7;
      case 'active': return 0.4;
      case 'urgent': return 0.2;
      default: return 0.1;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.grey;
      case 'in progress': return Colors.blueAccent;
      case 'active': return Colors.green;
      case 'urgent': return Colors.orange;
      default: return Colors.teal;
    }
  }
}
