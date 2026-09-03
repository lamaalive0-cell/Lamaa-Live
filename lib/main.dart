import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const LamaaLiveApp());
}

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
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
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
          titleTextStyle: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainNavigationScreen(),
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

// --- 1. الشاشة الرئيسية ---
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
          Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFFD700)),
          SizedBox(width: 10),
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

// --- 2. شاشة الألعاب ---
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

// --- 3. شاشة المنشورات ---
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

// --- 4. شاشة الرسائل ---
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

// --- 5. شاشة الحساب الشخصي ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const CircleAvatar(radius: 50, backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, size: 60, color: Colors.black)),
          const SizedBox(height: 15),
          const Text('الملك لمعة 👑', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
          const Text('ID: 10002000', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('متابع', '1.2K'), _buildStat('متابعة', '350'), _buildStat('أصدقاء', '85'),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: const [Text('🪙 25,000', style: TextStyle(fontSize: 18, color: Color(0xFFFFD700))), Text('رصيد الذهب', style: TextStyle(fontSize: 12))]),
                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)), child: const Text('شحن', style: TextStyle(color: Colors.black))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildOption(Icons.workspace_premium, 'عضوية VIP (4 مستويات)'),
          _buildOption(Icons.apartment, 'نظام الوكالات'),
          _buildOption(Icons.settings, 'الإعدادات'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) => Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54))]);
  Widget _buildOption(IconData icon, String label) => ListTile(leading: Icon(icon, color: const Color(0xFFFFD700)), title: Text(label), trailing: const Icon(Icons.arrow_forward_ios, size: 14));
}
