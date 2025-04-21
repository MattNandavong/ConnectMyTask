import 'package:app/model/task.dart';
import 'package:app/widget/make_offer_modal.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/task_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  final formatter = DateFormat.yMMMMd();

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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${task.title}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Description: ${task.description}'),
                SizedBox(height: 10),
                Text('Budget: \$${task.budget.toStringAsFixed(2)}'),
                SizedBox(height: 10),
                Text('Deadline: ${formatter.format(task.deadline)}'),
                SizedBox(height: 20),
                Divider(),
                Text('Posted by:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    task.user.buildAvatar(radius: 16),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icon(Icons.star, size: 12, color: Color(0xFFFFB700)),
                            SizedBox(width: 4),
                            Text(
                              task.user.averageRating != null
                                  ? task.user.averageRating!.toStringAsFixed(1)
                                  : 'No reviews yet',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => showMakeOfferModal(context, taskId),
          icon: Icon(Icons.local_offer_outlined),
          label: Text('Make an Offer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
