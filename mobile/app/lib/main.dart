import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app/widget/splash_screen.dart';

import 'package:google_fonts/google_fonts.dart';

var kColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: const Color.fromARGB(255, 1, 156, 71),
  onPrimary: Colors.white,
  secondary: Color.fromRGBO(33, 66, 150, 1),
  onSecondary: Colors.white,
  error: Color.fromRGBO(255, 146, 75, 1),
  onError: Colors.white,
  surface: const Color.fromARGB(255, 247, 255, 253),
  onSurface: const Color.fromARGB(255, 0, 104, 81),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: kColorScheme.onPrimaryContainer,
          foregroundColor: kColorScheme.primaryContainer,
        ),
        // cardTheme: CardTheme(
        //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        //   // shadowColor: const Color.fromARGB(0, 255, 193, 7),
        // ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: GoogleFonts.figtree(
            color: kColorScheme.secondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.figtree(fontSize: 16),
          activeIndicatorBorder: BorderSide(
            width: 3,
            color: kColorScheme.primary,
          ),
          outlineBorder: BorderSide(width: 2, color: kColorScheme.primary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: kColorScheme.onSurface),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: kColorScheme.primary),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          fillColor: kColorScheme.surface,
          focusColor: kColorScheme.surface,
          isCollapsed: false,
          floatingLabelStyle: GoogleFonts.figtree(fontSize: 20),
        ),
        scaffoldBackgroundColor: kColorScheme.surface,
      ),
      home: SplashScreen(),
      
    );
  }
}
