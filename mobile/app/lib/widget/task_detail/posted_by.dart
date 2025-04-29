import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostedByUser extends StatelessWidget {
  final User user;

  const PostedByUser({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posted by: ',
          style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            user.buildAvatar(radius: 18),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
