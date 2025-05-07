import 'dart:convert';
import 'package:app/model/bid.dart';
import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/task_detail/comment_section.dart';
import 'package:app/widget/screen/edit_task_screen.dart';
import 'package:app/widget/task_detail/Image_section.dart';
import 'package:app/widget/task_detail/assigned_provider.dart';
import 'package:app/widget/task_detail/basic_info.dart';
import 'package:app/widget/task_detail/map_section.dart';
import 'package:app/widget/task_detail/mark_complete_button.dart';
import 'package:app/widget/task_detail/posted_by.dart';
import 'package:app/widget/task_detail/status_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTaskDetails extends StatefulWidget {
  final String taskId;
  MyTaskDetails({super.key, required this.taskId});

  @override
  State<MyTaskDetails> createState() => _MyTaskDetailsState();
}

class _MyTaskDetailsState extends State<MyTaskDetails> {
  final formatter = DateFormat.yMMMMd();
  

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    final user = jsonDecode(userJson);
    return user['_id'] ?? user['id'];
  }

  Future<Map<String, User>> fetchProvidersForBids(List<Bid> bids) async {
    final Map<String, User> providerMap = {};
    for (var bid in bids) {
      if (!providerMap.containsKey(bid.provider)) {
        final user = await AuthService().getUserProfile(bid.provider);
        providerMap[bid.provider] = user;
      }
    }
    return providerMap;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task>(
      future: TaskService().getTask(widget.taskId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final task = snapshot.data!;
        final user = task.user;

        return FutureBuilder<String?>(
          future: _getCurrentUserId(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final currentUserId = userSnapshot.data;
            final isPoster = currentUserId == task.user.id;
            // final isCompleted = task.status.toLowerCase() == 'completed';

            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                surfaceTintColor: Colors.white,
                elevation: 8,
                title: Text('Task Details'),
                actions: [
                  if (isPoster && task.status.toLowerCase() != "in progress")
                    IconButton(
                      icon: Icon(Icons.edit_rounded),
                      tooltip: 'Edit Task',
                      onPressed: () {
                        // Navigate to Edit Task screen (you'll implement it)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskScreen(task: task),
                          ),
                        );
                      },
                    ),
                  //MARK AS COMPLETE BUTTON
                  if (task.status.toLowerCase() == 'in progress' && isPoster)
                    MarkAsCompleteBtn(task: task),
                ],
              ),

              body: Stack(
                children: [
                  // BACKGROUND STATUS SECTION
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TaskStatusHeader(task: task, isPoster: isPoster),
                  ),

                  //  MAIN CONTENT
                  Positioned.fill(
                    top: 80, // Leaves room for the status section
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //BASIC INFO SECTION
                            BasicInfo(task: task, formatter: formatter),
                            // IMAGES SECTION
                            ImageSection(images: task.images),

                            // LOCATION DETAILS SECTION
                            SizedBox(height: 20),
                            LocationSection(location: task.location),

                            //POSTED BY USER SECTION
                            SizedBox(height: 20),
                            PostedByUser(user: user),

                            // ASSIGNED TO PROVIDER SECTION WITH CHAT
                            SizedBox(height: 20),
                            AssignedProviderSection(
                              task: task,
                              currentUserId: currentUserId!,
                            ),

                            //COMMENT SECTION
                            Text(
                              'Comments',
                              style: GoogleFonts.figtree(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            CommentSection(taskId: task.id),
                            SizedBox(height: 20),
                            SizedBox(height: 100),
                          ],
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
}
