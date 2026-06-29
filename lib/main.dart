import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/app_shell.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a clean dashboard layout.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Try to initialise Firebase; fall back to demo mode on failure.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('⚠ Firebase init failed – running in DEMO mode.\n  $e');
    FirebaseService().enableDemoMode();
  }

  runApp(const NephTrapApp());
}

class NephTrapApp extends StatelessWidget {
  const NephTrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── User Specification: Kantung Semar Light Palette ──────────────────────
    const primaryGreen = Color(0xFF2E7D32); // Hijau Kantung Semar
    const bgPudar = Color(0xFFF1F8E9); // Hijau Sangat Pudar
    const surfaceWhite = Color(0xFFFFFFFF); // Putih Bersih

    return MaterialApp(
      title: 'NephTrap',
      debugShowCheckedModeBanner: false,

      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          surface: surfaceWhite,
          surfaceContainerHigh: surfaceWhite,
          brightness: Brightness.light,
        ),

        // Typography — Inter via Google Fonts
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),

        scaffoldBackgroundColor: bgPudar,

        appBarTheme: const AppBarTheme(
          backgroundColor: bgPudar,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryGreen),
        ),
      ),

      home: const AppShell(),
    );
  }
}
