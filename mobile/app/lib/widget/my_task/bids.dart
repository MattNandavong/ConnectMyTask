import 'package:flutter/material.dart';
import 'package:app/model/bid.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

void showBidsModal({
  required BuildContext context,
  required List<Bid> bids,
  required String taskId,
  required VoidCallback onBidAccepted,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,

    builder: (context) {
      final height = MediaQuery.of(context).size.height * 0.9;
      return Container(
        height: height,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "All Bids",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ...bids
                .map(
                  (bid) => _buildBidCard(context, bid, taskId, onBidAccepted),
                )
                .toList(),
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
  return FutureBuilder<User>(
    future: AuthService().getUserProfile(bid.provider),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      final provider = snapshot.data!;
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${timeago.format(bid.date)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.name.toUpperCase(),
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '\$${bid.price}',
                    style: GoogleFonts.oswald(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${bid.comment}',
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),

                  Text('Estimate time: ${bid.estimatedTime}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProfileScreen(
                                  user: provider,
                                  editable: false,
                                ),
                          ),
                        ),
                    child: Text("View profile"),
                  ),
                  FilledButton(
                    onPressed: () {
                      TaskService()
                          .acceptBid(taskId, bid.id)
                          .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Bid accepted successfully!'),
                              ),
                            );
                            Navigator.pop(context);
                            onBidAccepted();
                          })
                          .catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $error')),
                            );
                          });
                    },
                    child: Text('Accept Offer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
