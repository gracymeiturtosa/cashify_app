import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For desktop SQLite
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/report_provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite based on platform
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Desktop: Use sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android/iOS: Use sqflite natively (no FFI needed)

  // Initialize DatabaseService (assuming it needs async setup)
  await DatabaseService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    DatabaseService().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashify POS', // Changed from 'UkayPOS' to make it generic
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF9FE870), // Bright Green
        scaffoldBackgroundColor: const Color(0xFF121511), // Base Dark
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9FE870), // Bright Green
          foregroundColor: Color(0xFF163300), // Forest Green
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9FE870), // Bright Green
            foregroundColor: const Color(0xFF163300), // Forest Green
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            textStyle: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.25,
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? const Color(0xFF163300) : Colors.grey,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9FE870),
          secondary: Color(0xFF163300),
          surface: Color(0xFF1E231F), // Base Dark
          onPrimary: Color(0xFF163300),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFFFFFFFF),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.inter(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            height: 0.85,
            color: const Color(0xFFFFFFFF),
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            height: 0.85,
            color: const Color(0xFFFFFFFF),
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: -2.5 / 100,
            height: 34 / 30,
            color: const Color(0xFFFFFFFF),
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.5 / 100,
            height: 32 / 26,
            color: const Color(0xFFFFFFFF),
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.5 / 100,
            height: 28 / 22,
            color: const Color(0xFFFFFFFF),
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -1 / 100,
            height: 24 / 18,
            color: const Color(0xFFFFFFFF),
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5 / 100,
            height: 20 / 14,
            color: const Color(0xFFFFFFFF),
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: -0.5 / 100,
            height: 24 / 16,
            color: const Color(0xFFFFFFFF),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5 / 100,
            height: 24 / 16,
            color: const Color(0xFFFFFFFF),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.25 / 100,
            height: 22 / 14,
            color: const Color(0xFFFFFFFF),
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1 / 100,
            height: 24 / 16,
            color: const Color(0xFF163300),
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.25 / 100,
            height: 22 / 14,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}