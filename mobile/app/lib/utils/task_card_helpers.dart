import 'package:app/model/task.dart';
import 'package:app/widget/bid/make_offer_modal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TaskCardHelpers {
  static const Color urgentColor = Color.fromRGBO(255, 105, 6, 1);
  static const Color ongoingColor = Color.fromRGBO(0, 164, 74, 1);
  static const Color completedColor = Color.fromRGBO(168, 168, 168, 1);
  static const Color inProgressColor = Color.fromARGB(255, 10, 171, 235);

  static Text getStatusText(String status, [double? fontSize]) {
    switch (status) {
      case "Active":
        return _buildStatus('ONGOING', ongoingColor, fontSize);
      case "In Progress":
        return _buildStatus('IN PROGRESS', inProgressColor, fontSize);
      case "Urgent":
        return _buildStatus('URGENT', urgentColor, fontSize);
      case "Completed":
        return _buildStatus('COMPLETED', completedColor, fontSize);
      default:
        return Text('');
    }
  }

  static Widget getTaskDetail(context, Task task, bool minimise) {
    final priceFont = GoogleFonts.oswald(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).colorScheme.secondary,
    );

    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // width: 320,
              constraints: BoxConstraints(maxWidth: 320),
              height: 70,
              // padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.figtree(fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            //make offer and budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 100),
                      child: Text(
                        task.location!.type == "remote"
                            ? "Remote"
                            : task.location!.address ?? "Unknown Address",

                        style: GoogleFonts.figtree(
                          fontSize: 12,
                          // color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      task.deadline != null
                          ? DateFormat.yMMMd().format(task.deadline!)
                          : "Flexible",
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        // color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 120,
                  // height: 50,
                  child: Center(
                    child: Text('AUD ${task.budget}', style: priceFont),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (minimise == false)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      task.user.buildAvatar(radius: 10),
                      SizedBox(width: 5),
                      Text(task.user!.name),
                      SizedBox(width: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color.fromARGB(255, 255, 183, 0),
                            size: 14,
                          ),

                          Text(
                            task.user.averageRating.toString(),
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(
                child: task.status.toLowerCase() != 'completed'? FilledButton(
                  onPressed: () {
                    showMakeOfferModal(context, task.id);
                  },
                  child: Text('Make offer'),
                ): OutlinedButton(onPressed: (){}, child: Text('Comppleted')),
              ),
            ],
          ),
      ],
    );
  }

  static Text _buildStatus(String label, Color color, [double? size]) {
    return Text(
      label,
      style: GoogleFonts.figtree(
        fontSize: size ?? 16.0, // fallback to 16 if size is null
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
