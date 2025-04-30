import 'package:app/model/task.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BasicInfo extends StatelessWidget {
  final Task task;
  final DateFormat formatter;

  const BasicInfo({required this.task, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title.toUpperCase(),
          style: GoogleFonts.figtree(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 12),
        Text(task.description, style: GoogleFonts.figtree(fontSize: 15)),
        SizedBox(height: 12),
        Row(
          children: [
            Text(
              '${task.budget.toStringAsFixed(2)}',
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
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
              task.deadline != null
                  ? 'Deadline: ${formatter.format(task.deadline!)}'
                  : 'Deadline: Flexible',
              style: GoogleFonts.figtree(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
