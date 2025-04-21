import 'dart:convert';
import 'package:app/model/bid.dart';
import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/chat_screen.dart';
import 'package:app/widget/make_offer_modal.dart';
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
              Text(
                'All Bids',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                  TaskService()
                      .acceptBid(taskId, bid.id)
                      .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bid accepted successfully!')),
                        );
                        Navigator.pop(context);
                        onBidAccepted();
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to accept bid: $error'),
                          ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Task Details')),
      body: FutureBuilder<Task>(
        future: TaskService().getTask(taskId),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final task = snapshot.data!;
          final user = task.user;

          return FutureBuilder<String?>(
            future: _getCurrentUserId(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData)
                return Center(child: CircularProgressIndicator());
              final currentUserId = userSnapshot.data;
              final isPoster = currentUserId == task.user.id;
              final isCompleted = task.status.toLowerCase() == 'completed';

              return Stack(
                children: [
                  // BACKGROUND STATUS SECTION
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      color: _getStatusColor(task.status).withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            
                            children: [
                              Text(
                                task.status == 'Active'
                                    ? 'WAITING OFFERS'
                                    : task.status.toUpperCase(),
                                style: GoogleFonts.oswald(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(task.status),
                                ),
                              ),
                              if (isPoster &&
                                  task.bids.isNotEmpty &&
                                  task.assignedProvider == null) ...[
                                // Divider(),
                                // Text(
                                //   'Offers',
                                //   style: GoogleFonts.figtree(
                                //     fontSize: 14,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                // SizedBox(height: 8),
                                // Text('Total offers: ${task.bids.length}'),
                                FilledButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    // padding: EdgeInsets.symmetric(
                                    //   horizontal: 8,
                                    //   vertical: 4,
                                    // ),
                                    minimumSize: Size(
                                      0,
                                      24,
                                    ), // Optional: sets a smaller height baseline
                                  ),
                                  icon: Icon(
                                    Icons.visibility,
                                    size: 12,
                                  ), // Smaller icon
                                  label: Text(
                                    'View Offers',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ), // Smaller text
                                  ),
                                  onPressed: () {
                                    showBidsModal(
                                      context: context,
                                      bids: task.bids,
                                      taskId: task.id,
                                      onBidAccepted: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => MyTaskDetails(
                                                  taskId: task.id,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          // SizedBox(height: 6),
                          LinearProgressIndicator(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            value: _getStatusProgress(task.status),
                            backgroundColor: Colors.grey.shade300,
                            color: _getStatusColor(task.status),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ MAIN CONTENT
                  Positioned.fill(
                    top: 80, // Leaves room for the status section
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),

                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: GoogleFonts.figtree(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                task.description,
                                style: GoogleFonts.figtree(fontSize: 15),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  // Icon(Icons.attach_money_rounded, color: Theme.of(context).colorScheme.secondary),
                                  // SizedBox(width: 6),
                                  Text(
                                    '${task.budget.toStringAsFixed(2)}',
                                    style: GoogleFonts.oswald(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  // Icon(Icons.calendar_today, size: 18),
                                  // SizedBox(width: 6),
                                  Text(
                                    'Deadline: ${formatter.format(task.deadline)}',
                                    style: GoogleFonts.figtree(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Posted by: ',
                                style: GoogleFonts.figtree(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Divider(),
                              Row(
                                children: [
                                  user.buildAvatar(radius: 18),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Text(
                                      //   user.email,
                                      //   style: TextStyle(
                                      //     fontSize: 12,
                                      //     color: Colors.grey,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              // show privider brief profile if task assigned
                              if (task.assignedProvider != null) ...[
                                FutureBuilder<User>(
                                  future: AuthService().getUserProfile(
                                    task.assignedProvider!,
                                  ),
                                  builder: (context, providerSnapshot) {
                                    if (providerSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (!providerSnapshot.hasData) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          'Failed to load provider info',
                                        ),
                                      );
                                    }

                                    final provider = providerSnapshot.data!;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .assignment_turned_in_outlined,
                                                color: Colors.teal,
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'This task is assigned to:',
                                                  style: GoogleFonts.figtree(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Container(
                                          child: Row(
                                            children: [
                                              provider.buildAvatar(radius: 18),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      provider.name,
                                                      style:
                                                          GoogleFonts.figtree(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),

                                                    Text(
                                                      provider.averageRating !=
                                                                  null ||
                                                              provider.averageRating! >
                                                                  0
                                                          ? '⭐ ${provider.averageRating!.toStringAsFixed(1)}'
                                                          : 'No rating yet',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              ElevatedButton.icon(
                                                icon: Icon(
                                                  Icons.chat_bubble_outline,
                                                ),
                                                label: Text("Open Chat"),
                                                style: ElevatedButton.styleFrom(
                                                  // backgroundColor: Colors.blueAccent,
                                                  // foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) => ChatScreen(
                                                            taskId: task.id,
                                                            userId:
                                                                currentUserId!,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(40.0),
        child: ElevatedButton.icon(
          onPressed: () => showMakeOfferModal(context, taskId),
          icon: Icon(Icons.local_offer_outlined),
          label: Text('Make an Offer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  double _getStatusProgress(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 1.0;
      case 'in progress':
        return 0.7;
      case 'active':
        return 0.4;
      case 'urgent':
        return 0.2;
      default:
        return 0.1;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.grey;
      case 'in progress':
        return Colors.blueAccent;
      case 'active':
        return Colors.green;
      case 'urgent':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}
