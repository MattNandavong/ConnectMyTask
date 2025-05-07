import 'package:app/utils/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app/widget/screen/splash_screen.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:app/utils/theme_notifier.dart';

var kLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: const Color.fromARGB(255, 1, 156, 71),
  onPrimary: Colors.white,

  secondary: const Color.fromRGBO(33, 66, 150, 1),
  onSecondary: Colors.white,

  error: const Color.fromRGBO(255, 146, 75, 1),
  onError: Colors.white,

  surface: const Color.fromARGB(255, 255, 255, 255),
  onSurface: const Color.fromARGB(255, 0, 104, 81),

  background: const Color.fromARGB(255, 250, 250, 250),
  onBackground: const Color.fromARGB(255, 0, 104, 81),

  primaryContainer: const Color.fromARGB(255, 231, 231, 231), // Light green
  onPrimaryContainer: const Color.fromARGB(255, 255, 255, 255), // Dark green

  secondaryContainer: const Color.fromARGB(255, 197, 202, 233), // Light blue
  onSecondaryContainer: const Color.fromARGB(255, 26, 35, 126), // Dark blue

  tertiary: const Color.fromARGB(255, 255, 214, 0), // Yellow tertiary
  onTertiary: Colors.black,

  tertiaryContainer: const Color.fromARGB(255, 255, 243, 128), // Light yellow
  onTertiaryContainer: const Color.fromARGB(255, 102, 60, 0), // Brownish

  outline: const Color.fromARGB(255, 189, 189, 189), // Grey outline
  outlineVariant: const Color.fromARGB(255, 224, 224, 224),

  shadow: Colors.black26, // Light shadow

  inversePrimary: const Color.fromARGB(255, 0, 200, 83), // Bright green
  inverseSurface: const Color.fromARGB(
    255,
    239,
    239,
    239,
  ), // Dark surface for inverse
  onInverseSurface: Colors.white,

  scrim: Colors.black38, // Scrim over background when drawer or modal opens

  surfaceVariant: const Color.fromARGB(
    255,
    240,
    240,
    240,
  ), // Slightly darker surface variant
  onSurfaceVariant: const Color.fromARGB(255, 60, 60, 60),
);

var kDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: const Color.fromARGB(255, 1, 156, 71),
  onPrimary: Colors.white, // Keep text white on primary buttons

  secondary: const Color.fromRGBO(90, 120, 255, 1), // softer blue
  onSecondary: Colors.white,

  error: const Color.fromRGBO(255, 99, 71, 1), // soft red
  onError: Colors.black,

  background: const Color(0xFF1F1F1F), // soft dark grey background
  onBackground: Colors.white,

  surface: const Color(0xFF2C2C2C), // softer dark surface (cards, sheets)
  onSurface: Colors.white,

  primaryContainer: const Color(0xFF004D40), // dark teal
  onPrimaryContainer: Colors.white,

  secondaryContainer: const Color(0xFF1C2331), // deep blue-grey
  onSecondaryContainer: Colors.white,

  tertiary: const Color(0xFFFFC107), // amber yellow for accents
  onTertiary: Colors.black,

  tertiaryContainer: const Color(0xFFFFE082), // soft yellow background
  onTertiaryContainer: Colors.black,

  outline: const Color(0xFF757575), // medium grey
  outlineVariant: const Color(0xFF424242), // dark grey

  shadow: Colors.black87, // soft but visible shadow

  inversePrimary: const Color(0xFF00E676), // bright green for highlighting
  inverseSurface: const Color(0xFFE0E0E0), // light grey for inverse
  onInverseSurface: Colors.black,

  scrim: Colors.black45, // slightly lighter scrim (drawer overlay)

  surfaceVariant: const Color(0xFF3A3A3A), // even softer variant for containers
  onSurfaceVariant: Colors.white70,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(); //
  await setupFCM();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('lo')],
      path: 'lib/assets/translation',
      fallbackLocale: Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'ConnectMyTask',
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      themeMode: themeNotifier.themeMode,
      darkTheme: ThemeData().copyWith(
        primaryTextTheme: GoogleFonts.figtreeTextTheme(),
        colorScheme: kDarkColorScheme,
        useMaterial3: true,

        appBarTheme: AppBarTheme(
          backgroundColor: kDarkColorScheme.surface,
          foregroundColor: kDarkColorScheme.onSurface,
        ),

        cardTheme: CardTheme(
          color: kDarkColorScheme.surface,
          surfaceTintColor: kDarkColorScheme.surface,
        ),

        textTheme: ThemeData.dark().textTheme.copyWith(
          titleLarge: GoogleFonts.figtree(
            color: kDarkColorScheme.secondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.figtree(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          fillColor: kDarkColorScheme.surfaceVariant,
          filled: true,
          floatingLabelStyle: GoogleFonts.figtree(
            fontSize: 20,
            color: kDarkColorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),

        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: kDarkColorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.tealAccent, width: 2),
            ),
          ),
        ),

        scaffoldBackgroundColor: kDarkColorScheme.background,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kDarkColorScheme.tertiary,
          elevation: 8,
          actionTextColor: kDarkColorScheme.secondary,
          contentTextStyle: TextStyle(color: kDarkColorScheme.onTertiary),
        ),
      ),
      theme: ThemeData().copyWith(
        colorScheme: kLightColorScheme,
        primaryTextTheme: GoogleFonts.figtreeTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: kLightColorScheme.surface,
          foregroundColor: kLightColorScheme.onSurface,
        ),
        // cardTheme: CardTheme(
        //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        //   // shadowColor: const Color.fromARGB(0, 255, 193, 7),
        // ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: GoogleFonts.figtree(
            color: kLightColorScheme.secondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        cardTheme: ThemeData().cardTheme.copyWith(color: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.figtree(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kLightColorScheme.onSurface,
          ),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          fillColor: kLightColorScheme.inverseSurface,
          filled: true,
          focusColor: kLightColorScheme.inverseSurface,
          isCollapsed: false,
          floatingLabelStyle: GoogleFonts.figtree(
            fontSize: 20,
            color: kLightColorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            filled: true, // Fill background
            fillColor: Colors.white, // White background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // rounded corners
              borderSide: BorderSide(
                color: Colors.grey, // Border color
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.teal, // Highlight color when focused
                width: 2,
              ),
            ),
          ),
        ),
        scaffoldBackgroundColor: kLightColorScheme.background,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kLightColorScheme.tertiary,
          elevation: 8,
          actionTextColor: kLightColorScheme.secondary,
          contentTextStyle: TextStyle(color: kLightColorScheme.onTertiary),
        ),
      ),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      home: SplashScreen(),
    );
  }
}
