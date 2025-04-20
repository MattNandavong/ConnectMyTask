import 'package:app/model/task.dart';
import 'package:app/widget/make_offer_modal.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/task_service.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Details')),
      body: FutureBuilder<Task>(
        future: TaskService().getTask(taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Task not found'));
          }
          final task = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${task.title}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 10),
                Text('Description: ${task.description}'),
                SizedBox(height: 10),
                Text('Budget: \$${task.budget}'),
                SizedBox(height: 10),
                Text('Deadline: ${task.deadline}'),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    task.user.buildAvatar(radius: 14),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.user.name,
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star, size: 8, color: Color(0xFFFFB700)),
                            SizedBox(width: 4),
                            Text(
                              task.user.rating != null
                                  ? task.user.rating!.toStringAsFixed(1)
                                  : 'No reviews yet',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
