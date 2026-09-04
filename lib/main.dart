import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fpwosplqsbnirjoleqaw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwd29zcGxxc2JuaXJqb2xlcWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0OTgyMDksImV4cCI6MjEwNDA3NDIwOX0.jnqNZIauBqUmQ-tyvdx3lKdhmLHTHj9wITd_01puIKw',
  );
  runApp(const LamaaLiveApp());
}

final supabase = Supabase.instance.client;

class LamaaLiveApp extends StatelessWidget {
  const LamaaLiveApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لمعة لايف',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA')],
      locale: const Locale('ar', 'SA'),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFFFA751),
          surface: Color(0xFF1A1A22),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A22),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) {
        if (supabase.auth.currentSession != null) return const MainNavigationScreen();
        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _signUp = false;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      if (_signUp) {
        await supabase.auth.signUp(
          email: _email.text.trim(),
          password: _password.text.trim(),
          data: {'username': _username.text.trim()},
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨ لمعة لايف ✨', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
              const SizedBox(height: 32),
              if (_signUp) TextField(controller: _username, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
              TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة السر')),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : Text(_signUp ? 'إنشاء حساب' : 'تسجيل الدخول'),
              ),
              TextButton(onPressed: () => setState(() => _signUp = !_signUp), child: Text(_signUp ? 'لديك حساب؟ سجل دخولك' : 'أنشئ حساباً جديداً', style: const TextStyle(color: Color(0xFFFFD700)))),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int i = 0;
  final screens = const [HomeScreen(), GamesScreen(), MomentsScreen(), MessagesScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: (v) => setState(() => i = v),
        backgroundColor: const Color(0xFF0F0F12),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'الألعاب'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'يومياتي'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الرسائل'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('✨ الرئيسية ✨')), body: const Center(child: Text('الغرف قريباً')));
  }
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('🎮 الألعاب')), body: const Center(child: Text('الألعاب قريباً')));
  }
}

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('📝 المنشورات')), body: const Center(child: Text('المنشورات قريباً')));
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('💬 الرسائل')), body: const Center(child: Text('الرسائل قريباً')));
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final res = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    if (mounted) setState(() => data = res);
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final gold = data?['gold_balance'] ?? 10000;
    final level = data?['user_level'] ?? 1;
    final points = data?['points_balance'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CircleAvatar(radius: 50, backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, size: 60, color: Colors.black))),
          const SizedBox(height: 12),
          Center(child: Text(data?['username'] ?? user?.email?.split('@').first ?? 'مستخدم', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
          const SizedBox(height: 24),
          
          // محفظة الذهب والعملات
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [Text('🪙 $gold', style: const TextStyle(fontSize: 18, color: Color(0xFFFFD700), fontWeight: FontWeight.bold)), const Text('رصيد الذهب', style: TextStyle(fontSize: 12))]),
                Column(children: [Text('💎 $points', style: const TextStyle(fontSize: 18, color: Colors.cyanAccent, fontWeight: FontWeight.bold)), const Text('نقاط الهدايا', style: TextStyle(fontSize: 12))]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // تفاصيل الحساب المتفق عليها
          _tile(Icons.star, 'المستوى الحالي', 'Lv.$level'),
          _tile(Icons.workspace_premium, 'عضوية VIP', 'عرض المستويات'),
          _tile(Icons.apartment, 'نظام الوكالة', 'لم تنضم لوكالة'),
          _tile(Icons.card_giftcard, 'صندوق الهدايا', '700 هدية'),
          _tile(Icons.history, 'سجل المعاملات', 'عرض الكل'),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
            onTap: () => supabase.auth.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData i, String t, String s) => ListTile(
    leading: Icon(i, color: const Color(0xFFFFD700)),
    title: Text(t),
    subtitle: Text(s, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    onTap: () {},
  );
}
