import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskCardHelpers {
  static const Color urgentColor = Color.fromRGBO(255, 146, 75, 1);
  static const Color ongoingColor = Color.fromRGBO(0, 203, 157, 1);
  static const Color completedColor = Color.fromRGBO(168, 168, 168, 1);
  static const Color inProgressColor = Color.fromARGB(255, 72, 185, 230);

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

  static Widget getTaskDetail(String title, String description, double budget) {
    final priceFont = GoogleFonts.oswald(
      fontSize: 14,
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 0, 127, 97),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 250,
          height: 70,
          // padding: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.figtree(fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 70,
          height: 50,
          child: Center(child: Text('AUD$budget', style: priceFont)),
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
