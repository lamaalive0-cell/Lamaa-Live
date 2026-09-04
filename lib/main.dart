import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase بالرابط والمفتاح الخاص بمشروعك
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
      title: 'لمعة لايف - Lamaa Live',
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

// بوابة التوثيق: فحص هل المستخدم مسجل دخول أم لا
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          return const MainNavigationScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

// شاشة تسجيل الدخول وإنشاء الحساب
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {'username': _usernameController.text.trim()},
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح!')),
          );
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ غير متوقع'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // تسجيل الدخول عن طريق جوجل
  Future<void> _signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في دخول جوجل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨ لمعة لايف ✨', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                const SizedBox(height: 8),
                Text(_isSignUp ? 'أنشئ حسابك الجديد للانضمام' : 'مرحباً بك مجدداً، سجل دخولك', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 32),
                if (_isSignUp)
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person, color: Color(0xFFFFD700))),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email, color: Color(0xFFFFD700))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة السر', prefixIcon: Icon(Icons.lock, color: Color(0xFFFFD700))),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(_isSignUp ? 'إنشاء حساب جديد' : 'تسجيل الدخول', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                
                // زر تسجيل الدخول عن طريق جوجل
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Color(0xFFFFD700)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.g_mobiledata, color: Color(0xFFFFD700), size: 30),
                  label: const Text('التسجيل بواسطة Google', style: TextStyle(color: Colors.white)),
                  onPressed: _signInWithGoogle,
                ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? 'لديك حساب بالفعل؟ سجل دخولك' : 'ليس لديك حساب؟ أنشئ حساباً الآن', style: const TextStyle(color: Color(0xFFFFD700))),
                ),
              ],
            ),
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
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    GamesScreen(),
    MomentsScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.1), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0F0F12),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFFD700),
          unselectedItemColor: Colors.white54,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'الألعاب'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion), label: 'يومياتي'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'الرسائل'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.search, color: Color(0xFFFFD700)),
        title: const Text('✨ لمعة لايف ✨'),
        actions: const [
          Icon(Icons.notifications_none, color: Color(0xFFFFD700)),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: ['🌟 المميزة', '🇸🇦 السعودية', '🇪🇬 مصر', '🇮🇶 العراق', '🎮 ألعاب', '🎵 طرب']
                    .map((cat) => Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                          ),
                          child: Text(cat, style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A22),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 30, backgroundColor: Color(0xFF0F0F12), child: Icon(Icons.mic, color: Color(0xFFFFD700))),
                    const SizedBox(height: 10),
                    Text('غرفة لمعة #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('👥 5/12', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map> games = [
      {'n': 'لودو', 'i': '🎲'}, {'n': 'دومينو', 'i': '🁣'},
      {'n': 'عجلة الحظ', 'i': '🎡'}, {'n': 'GreedyCat', 'i': '🐱'},
      {'n': 'Olympus', 'i': '⚡'}, {'n': 'Fishing', 'i': '🐟'},
      {'n': 'Roulette', 'i': '🎰'}, {'n': 'بوكر', 'i': '🃏'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 ساحة الألعاب')),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: games.length,
        itemBuilder: (context, i) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A22),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(games[i]['i'], style: const TextStyle(fontSize: 40)),
              Text(games[i]['n'], style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 المنشورات اليومية')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, color: Colors.black)),
                  SizedBox(width: 10),
                  Text('مستخدم لمعة', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 15),
              const Text('هذا منشور تجريبي في تطبيق لمعة لايف الجديد! ✨👑'),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.favorite_border, size: 20),
                  Icon(Icons.comment_outlined, size: 20),
                  Icon(Icons.card_giftcard, color: Color(0xFFFFD700), size: 20),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 الرسائل')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, i) => ListTile(
          leading: const CircleAvatar(backgroundColor: Color(0xFF1A1A22), child: Icon(Icons.person_outline, color: Color(0xFFFFD700))),
          title: Text('صديق لمعة $i'),
          subtitle: const Text('كيفك اليوم؟ يلا نلعب..'),
          trailing: const Text('12:00 م', style: TextStyle(fontSize: 10, color: Colors.white24)),
        ),
      ),
    );
  }
}

// البروفايل الحقيقي المربوط بقاعدة البيانات
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: FutureBuilder<Map<String, dynamic>>(
        future: supabase.from('profiles').select().eq('id', user?.id ?? '').single(),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final username = profile?['username'] ?? user?.email?.split('@')[0] ?? 'مستخدم لمعة';
          final gold = profile?['gold_balance'] ?? 10000;

          return Column(
            children: [
              const SizedBox(height: 60),
              const CircleAvatar(radius: 50, backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, size: 60, color: Colors.black)),
              const SizedBox(height: 15),
              Text(username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
              Text(user?.email ?? '', style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [Text('🪙 $gold', style: const TextStyle(fontSize: 18, color: Color(0xFFFFD700))), const Text('رصيد الذهب الحقيقي', style: TextStyle(fontSize: 12))]),
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)), child: const Text('شحن', style: TextStyle(color: Colors.black))),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
                onTap: () async => await supabase.auth.signOut(),
              ),
            ],
          );
        },
      ),
    );
  }
}
