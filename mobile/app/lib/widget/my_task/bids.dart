import 'package:app/model/bid.dart';
import 'package:app/model/task.dart';
import 'package:app/utils/task_service.dart';
import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeago;

class BidsScreen extends StatelessWidget {
  final List<Bid> bids;
  final String taskId;

  BidsScreen({required this.bids, required this.taskId});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('All Bids'),
      ),
      body: ListView.builder(
        itemCount: bids.length,
        itemBuilder: (context, index) {
          final bid = bids[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bid by: ${bid.provider}'),
                Text('Price: \$${bid.price}'),
                Text('Estimated Time: ${bid.estimatedTime} days'),
                Text('Bid made: ${timeago.format(bid.date)}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Implement navigation to provider profile screen
                      },
                      child: Text('View Profile'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implement accept offer functionality
                        TaskService().acceptBid(taskId, bid.id).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Bid accepted successfully!'),
                            ),
                          );
                        }).catchError((error) {
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
        },
      ),
    );
  }
}
