import 'package:app/model/task.dart';
import 'package:app/widget/bid/bids.dart';
import 'package:app/widget/my_task/mytask_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskStatusHeader extends StatelessWidget {
  final Task task;
  final bool isPoster;

  const TaskStatusHeader({required this.task, required this.isPoster});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                FilledButton.icon(
                                  style: ElevatedButton.styleFrom(
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
    );
  }
}
