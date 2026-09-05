import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'room_screen.dart'; // هذا السطر يستدعي ملف الغرفة الذي أنشأناه

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // اتصال سوبابيز الخاص بمشروعك
  await Supabase.initialize(
    url: 'https://fpwosplqsbnirjoleqaw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwd29zcGxxc2JuaXJqb2xlcWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0OTgyMDksImV4cCI6MjEwNDA3NDIwOX0.jnqNZIauBqUmQ-tyvdx3lKdhmLHTHj9wITd_01puIKw',
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
      
      // هنا جعلنا التطبيق يفتح مباشرة على "شاشة الغرفة"
      home: const RoomScreen(roomId: 2), 
    );
  }
}
