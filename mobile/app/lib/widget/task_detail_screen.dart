import 'dart:convert';

import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/make_offer_modal.dart';
import 'package:app/widget/my_task/myTask_details.dart';
import 'package:app/widget/task_detail_body.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/task_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  final formatter = DateFormat.yMMMMd();

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    final user = jsonDecode(userJson);
    return user['_id'] ?? user['id'];
  }

  void _showImageGallery(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    PageController pageController = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 30,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task>(
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
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                title: Text('Task Details'),
                actions: [
                  if (isPoster && !isCompleted)
                    IconButton(
                      icon: Icon(Icons.edit_rounded),
                      tooltip: 'Edit Task',
                      onPressed: () {
                        // Navigate to Edit Task screen (you'll implement it)
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => EditTaskScreen(taskId: task.id),
                        //   ),
                        // );
                      },
                    ),
                ],
              ),

              body: Stack(
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

                  // MAIN CONTENT
                  TaskDetailBody(
                    task: task,
                    user: user,
                    isPoster: isPoster,
                    isCompleted: isCompleted,
                    currentUserId: currentUserId,
                    onMakeOffer: () => showMakeOfferModal(context, taskId),
                    // onMarkComplete: () => ,
                  ),
                  // Floating Make Offer Button
                  if (!isCompleted && !isPoster)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed:
                              task.assignedProvider == null
                                  ? () => showMakeOfferModal(context, taskId)
                                  : () => ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Task is under progress. Cannot make offer.",
                                      ),
                                    ),
                                  ),
                          icon: Icon(Icons.local_offer_outlined),
                          label: Text(
                            task.assignedProvider == null
                                ? 'Make an Offer'
                                : 'Task In Progress',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 55),
                            backgroundColor:
                                task.assignedProvider == null
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
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
