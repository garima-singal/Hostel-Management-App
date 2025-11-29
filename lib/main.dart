import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/auth/permission_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);
    const accentGray = Color(0xFFB0BEC5);

    return MaterialApp(
      title: 'HostelLink',
      theme: ThemeData(
        // General Theme
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: background,
          elevation: 4,
          iconTheme: IconThemeData(color: background),
          titleTextStyle: TextStyle(
            color: background,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            elevation: 5,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlue,
            side: const BorderSide(color: primaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: accentGray),
          hintStyle: const TextStyle(color: accentGray),
          prefixIconColor: primaryBlue,
        ),

        // Cards
        cardTheme: CardTheme(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),

        // Other UI Elements
        iconTheme: const IconThemeData(
          color: primaryBlue,
        ),
      ),
      home: const PermissionGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
