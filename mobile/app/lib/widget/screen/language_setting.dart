import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSetting extends StatelessWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return // Language Selector
    Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Language',
              style: GoogleFonts.figtree(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('English (EN)', style: GoogleFonts.figtree()),
            onTap: () async {
              await context.setLocale(Locale('en'));
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Lao (LO)', style: GoogleFonts.figtree()),
            onTap: () async {
              await context.setLocale(Locale('lo'));
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
