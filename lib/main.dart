import 'package:flutter/material.dart';
import 'package:jadmignaloux_appel/pages/login_page.dart';
import 'package:jadmignaloux_appel/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // <- important

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://laddqngvdbdlkikoybrd.supabase.co', // ton URL Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhZGRxbmd2ZGJkbGtpa295YnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDUzMDgsImV4cCI6MjA3MTg4MTMwOH0.uiSjrH-Vg2ESLgUhGUxWJHxurfm-qvyxsenpH5Py_E8',        // ta clé anonyme
  );
  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JAD Mignaloux',
      theme: ThemeData(
        primaryColor: const Color(0xFFDDAC17),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFDDAC17),
          secondary: const Color(0xFFECC440),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
