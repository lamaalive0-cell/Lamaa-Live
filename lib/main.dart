import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fpwosplqsbnirjoleqaw.supabase.co',
    anonKey: 'PASTE_YOUR_ANON_KEY_HERE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lamaa Live',
      theme: ThemeData.dark(),
      home: const LoginScreen(), // هنا شاشة الدخول
    );
  }
}
