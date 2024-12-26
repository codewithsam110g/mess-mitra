import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_mate/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.lightBlue, // Primary color as light blue
        scaffoldBackgroundColor: const Color(0xFFF8FAFF), // Light background
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF8FAFF),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // Button background color
            foregroundColor: Colors.white, // Text color
            textStyle: const TextStyle(fontSize: 16), // Text style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.lightBlue, // Text color for text buttons
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor:
                Colors.blueAccent, // Text color for outlined buttons
            side: BorderSide(color: Colors.blueAccent), // Border color
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent, // AppBar background color
          foregroundColor: Colors.white, // AppBar text and icon color
          centerTitle: true, // Center the title text
          elevation: 4, // Slight shadow effect
        ),
        cardTheme: CardTheme(
          color: const Color(0xFFF8FAFF), // Card background color
          elevation: 0, // Shadow effect
          margin: const EdgeInsets.all(8), // Default margin for cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
