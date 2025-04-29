import 'package:app/model/task.dart';
import 'package:app/utils/task_service.dart';
import 'package:flutter/material.dart';

class MarkAsCompleteBtn extends StatelessWidget {

  final Task task;
  const MarkAsCompleteBtn({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        //TODO: Implement simulated payment
        showDialog(
          context: context,
          builder: (context) {
            double rating = 5.0;
            TextEditingController commentController = TextEditingController();

            return AlertDialog(
              title: Text('How was your experience?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Rate the provider'),
                  SizedBox(height: 8),
                  StatefulBuilder(
                    builder:
                        (context, setState) => Slider(
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: rating.toString(),
                          value: rating,
                          onChanged: (val) => setState(() => rating = val),
                        ),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: 'Leave a comment...'),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await TaskService().completeTask(
                      task.id,
                      rating,
                      commentController.text.trim(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Task marked as completed!')),
                    );
                    Navigator.pop(context); // or refresh screen
                  },
                ),
              ],
            );
          },
        );
      },
      icon: Icon(Icons.done_all),
      label: Text('Mark as Completed'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14),
        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
