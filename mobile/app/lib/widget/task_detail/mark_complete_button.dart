import 'package:app/model/task.dart';
import 'package:app/utils/task_service.dart';
import 'package:flutter/material.dart';

class MarkAsCompleteBtn extends StatefulWidget {
  final Task task;
  const MarkAsCompleteBtn({super.key, required this.task});

  @override
  State<MarkAsCompleteBtn> createState() => _MarkAsCompleteBtnState();
}

class _MarkAsCompleteBtnState extends State<MarkAsCompleteBtn> {
  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _RatingDialog(taskId: widget.task.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showCompletionDialog(context),
      icon: Icon(Icons.done_all),
      label: Text('Complete'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final String taskId;
  const _RatingDialog({required this.taskId});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  double rating = 5.0;
  bool recommend = true;
  final TextEditingController commentController = TextEditingController();
  bool isSubmitting = false;

  void _submitReview() async {
    setState(() => isSubmitting = true);

    try {
      await TaskService().completeTask(
        widget.taskId,
        rating,
        commentController.text.trim(),
        recommend,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task marked as completed!')),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('How was your experience?'),
      content: isSubmitting
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Rate the provider'),
                  Slider(
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: rating.toString(),
                    value: rating,
                    onChanged: (val) => setState(() => rating = val),
                  ),
                  SizedBox(height: 16),
                  Text('Would you recommend this provider?'),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('Yes'),
                        selected: recommend == true,
                        onSelected: (_) => setState(() => recommend = true),
                        selectedColor:
                            Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: recommend == true ? Colors.white : null,
                        ),
                      ),
                      ChoiceChip(
                        label: Text('No'),
                        selected: recommend == false,
                        onSelected: (_) => setState(() => recommend = false),
                        selectedColor: Colors.redAccent,
                        labelStyle: TextStyle(
                          color: recommend == false ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: 'Leave a comment...'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            if (!isSubmitting) Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitReview,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
