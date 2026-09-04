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
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700), width: 2)),
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
    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      _toast('أدخل الإيميل وكلمة السر');
      return;
    }
    if (_signUp && _username.text.trim().isEmpty) {
      _toast('أدخل اسم المستخدم');
      return;
    }
    setState(() => _loading = true);
    try {
      if (_signUp) {
        await supabase.auth.signUp(
          email: _email.text.trim(),
          password: _password.text.trim(),
          data: {'username': _username.text.trim()},
        );
        _toast('تم إنشاء الحساب ✨', ok: true);
      } else {
        await supabase.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      }
    } on AuthException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('خطأ في الاتصال');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String m, {bool ok = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('✨ لمعة لايف ✨', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                  const SizedBox(height: 8),
                  Text(_signUp ? 'أنشئ حسابك للانضمام' : 'سجّل دخولك', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 28),
                  if (_signUp) ...[
                    TextField(controller: _username, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person, color: Color(0xFFFFD700)))),
                    const SizedBox(height: 12),
                  ],
                  TextField(controller: _email, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'البريد', prefixIcon: Icon(Icons.email, color: Color(0xFFFFD700)))),
                  const SizedBox(height: 12),
                  TextField(controller: _password, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'كلمة السر', prefixIcon: Icon(Icons.lock, color: Color(0xFFFFD700)))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text(_signUp ? 'إنشاء حساب' : 'تسجيل الدخول', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _signUp = !_signUp),
                    child: Text(_signUp ? 'لديك حساب؟ ادخل' : 'حساب جديد', style: const TextStyle(color: Color(0xFFFFD700))),
                  ),
                ],
              ),
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
  int i = 0;
  final pages = const [HomeScreen(), GamesScreen(), MomentsScreen(), MessagesScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: (v) => setState(() => i = v),
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
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ لمعة لايف'),
        actions: const [Icon(Icons.search, color: Color(0xFFFFD700)), SizedBox(width: 12), Icon(Icons.notifications_none, color: Color(0xFFFFD700)), SizedBox(width: 12)],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['🌟 مميزة', '🇸🇦 خليجي', '🇪🇬 مصري', '🇮🇶 عراقي', '🎮 ألعاب', '🎵 طرب']
                  .map((c) => Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
                        child: Text(c, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.88),
              itemCount: 6,
              itemBuilder: (_, index) => Container(
                decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.mic, color: Color(0xFFFFD700), size: 36),
                  const SizedBox(height: 8),
                  Text('غرفة لمعة #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('👥 قريباً: دخول حقيقي', style: TextStyle(fontSize: 10, color: Colors.white54)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = [('لودو', '🎲'), ('دومينو', '🁣'), ('عجلة الحظ', '🎡'), ('GreedyCat', '🐱'), ('Olympus', '⚡'), ('Fishing', '🐟'), ('Roulette', '🎰'), ('بوكر', '🃏')];
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 الألعاب')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: g.length,
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.25))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(g[i].$2, style: const TextStyle(fontSize: 40)),
            Text(g[i].$1, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          ]),
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
      appBar: AppBar(title: const Text('📝 يومياتي')),
      body: const Center(child: Text('المنشورات والستوري — المرحلة الجاية', style: TextStyle(color: Colors.white54))),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 الرسائل')),
      body: const Center(child: Text('المحادثات — المرحلة الجاية', style: TextStyle(color: Colors.white54))),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = supabase.auth.currentUser;
    if (u == null) return;
    try {
      final row = await supabase.from('profiles').select().eq('id', u.id).maybeSingle();
      if (row == null) {
        await supabase.from('profiles').upsert({
          'id': u.id,
          'email': u.email,
          'username': u.userMetadata?['username'] ?? u.email?.split('@').first,
          'gold_balance': 10000,
          'points_balance': 0,
          'user_level': 1,
          'xp': 0,
          'vip_level': 0,
        });
        final again = await supabase.from('profiles').select().eq('id', u.id).maybeSingle();
        if (mounted) setState(() { profile = again; loading = false; });
      } else {
        if (mounted) setState(() { profile = row; loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  String get _vipLabel {
    final v = profile?['vip_level'] ?? 0;
    switch (v) {
      case 1: return 'VIP 1 ⭐';
      case 2: return 'VIP 2 ⭐⭐';
      case 3: return 'VIP 3 ⭐⭐⭐';
      case 4: return 'VIP 4 👑';
      default: return 'بدون VIP';
    }
  }

  Color get _frameColor {
    final lv = (profile?['user_level'] ?? 1) as int;
    if (lv >= 91) return const Color(0xFFFF1744);
    if (lv >= 76) return Colors.cyanAccent;
    if (lv >= 51) return const Color(0xFFFFD700);
    if (lv >= 26) return Colors.blueGrey.shade200;
    if (lv >= 11) return const Color(0xFFCD7F32);
    return Colors.grey;
  }

  Future<void> _editProfile() async {
    final nameC = TextEditingController(text: profile?['username']?.toString() ?? '');
    final bioC = TextEditingController(text: profile?['bio']?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        title: const Text('تعديل البروفايل', style: TextStyle(color: Color(0xFFFFD700))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'الاسم')),
          TextField(controller: bioC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'البايو')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (ok == true && supabase.auth.currentUser != null) {
      await supabase.from('profiles').update({
        'username': nameC.text.trim(),
        'bio': bioC.text.trim(),
      }).eq('id', supabase.auth.currentUser!.id);
      await _load();
    }
  }

  void _openPage(String title, Widget body) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final u = supabase.auth.currentUser;
    final username = profile?['username'] ?? u?.userMetadata?['username'] ?? u?.email?.split('@').first ?? 'مستخدم';
    final gold = profile?['gold_balance'] ?? 10000;
    final points = profile?['points_balance'] ?? 0;
    final level = profile?['user_level'] ?? 1;
    final xp = profile?['xp'] ?? 0;
    final xpNeed = level * 100;
    final xpPct = (xp / xpNeed).clamp(0.0, 1.0);
    final bio = profile?['bio'] ?? 'عضو في لمعة لايف ✨';
    final country = profile?['country'] ?? '🇸🇦';
    final followers = profile?['followers_count'] ?? 0;
    final following = profile?['following_count'] ?? 0;
    final friends = profile?['friends_count'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: Color(0xFFFFD700)), onPressed: () => _openPage('الإعدادات', _settingsBody())),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : RefreshIndicator(
              color: const Color(0xFFFFD700),
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _frameColor, width: 3),
                        boxShadow: [BoxShadow(color: _frameColor.withOpacity(0.4), blurRadius: 12)],
                      ),
                      child: const CircleAvatar(radius: 44, backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, size: 52, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Text('$username | $country', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
                  Center(child: Text(u?.email ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12))),
                  const SizedBox(height: 6),
                  Center(child: Text(bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  const SizedBox(height: 16),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _stat('$followers', 'متابع'),
                    _stat('$following', 'متابعات'),
                    _stat('$friends', 'أصدقاء'),
                  ]),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(child: _walletCard('🪙', '$gold', 'ذهب', const Color(0xFFFFD700))),
                    const SizedBox(width: 10),
                    Expanded(child: _walletCard('💎', '$points', 'نقاط', Colors.cyanAccent)),
                  ]),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () => _openPage('شحن الذهب', const Center(child: Text('بوابة الشحن الحقيقي لاحقاً\n(Google Play / Apple)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)))),
                      child: const Text('💳 شحن الرصيد', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('المستوى Lv.$level', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                        Text('$xp / $xpNeed XP', styleconst TextStyle(fontSize: 11, color: Colors.white54)),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(value: xpPct, minHeight: 8, color: const Color(0xFFFFD700), backgroundColor: Colors.white12),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2A2A35), Color(0xFF1A1A22)]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
                    ),
                    child: InkWell(
                      onTap: () => _openPage('عضوية VIP', _vipBody()),child: Row(children: [
                        const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 32),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('عضوية VIP', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                          Text(_vipLabel, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ])),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFFFD700)),]),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _menuTile(Icons.apartment, 'الوكالة', () => _openPage('الوكالة', _agencyBody())),
                  _menuTile(Icons.card_giftcard, 'صندوق الهدايا (700)', () => _openPage('صندوق الهدايا', const Center(child: Text('جدار الهدايا — بعد تفعيل المتجر', style: TextStyle(color: Colors.white54))))),
                  _menuTile(Icons.history, 'سجل المعاملات', () => _openPage('المعاملات', _txBody())),
                  _menuTile(Icons.edit, 'تعديل البروفايل', _editProfile),
                  _menuTile(Icons.emoji_events, 'الإنجازات والبطولات', () => _openPage('البطولات', const Center(child: Text('البطولات الأسبوعية — قريباً', style: TextStyle(color: Colors.white54))))),
                  _menuTile(Icons.settings, 'الإعدادات', () => _openPage('الإعدادات', _settingsBody())),const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async => supabase.auth.signOut(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _stat(String v, String l) => Column(children: [
        Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
        Text(l, style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ]);Widget _walletCard(String icon, String v, String l, Color c) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.35))),
        child: Column(children: [
          Text('$icon $v', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
          Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      );

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFFFFD700), size: 22),
          title: Text(title, style: const TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white38),
          onTap: onTap,
        ),
      );
Widget _vipBody() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _vipCard(1, 'VIP 1 ⭐', '\$4.99', 'إطار برونزي · هدية يومية 100 ذهب · خصم 5%'),
          _vipCard(2, 'VIP 2 ⭐⭐', '\$9.99', 'إطار فضي · 300 ذهب/يوم · خصم 10% · أولوية غرف'),
          _vipCard(3, 'VIP 3 ⭐⭐⭐', '\$19.99', 'إطار ذهبي · 800 ذهب/يوم · خصم 15% · ترند يومي'),
          _vipCard(4, 'VIP 4 👑', '\$49.99', 'أسطوري · 2000 ذهب/يوم · خصم 25% · دعم خاص'),
        ],
      );Widget _vipCard(int lvl, String title, String price, String desc) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.35))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
      );Widget _agencyBody() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🏢 نظام الوكالات', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('• برونزي 50 عضو — عمولة 10%\n• فضي 150 — 13%\n• ذهبي 300 — 16%\n• ألماسي 500 — 20%', style: TextStyle(height: 1.6)),
        ]),
      );

  Widget _txBody() => FutureBuilder(
        future: supabase.from('transactions').select().order('created_at', ascending: false).limit(50),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          final list = snap.data as List? ?? [];
          if (list.isEmpty) return const Center(child: Text('لا معاملات بعد', style: TextStyle(color: Colors.white54)));return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              title: Text('${list[i]['type']} · ${list[i]['amount']} ${list[i]['currency'] ?? 'gold'}'),
              subtitle: Text('${list[i]['note'] ?? ''}'),
            ),
          );
        },
      );

  Widget _settingsBody() => ListView(
        children: [
          const ListTile(leading: Icon(Icons.lock, color: Color(0xFFFFD700)), title: Text('الخصوصية'), subtitle: Text('قريباً')),
          const ListTile(leading: Icon(Icons.notifications, color: Color(0xFFFFD700)), title: Text('الإشعارات'), subtitle: Text('قريباً')),
          const ListTile(leading: Icon(Icons.language, color: Color(0xFFFFD700)), title: Text('اللغة'), subtitle: Text('العربية')),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),onTap: () async {
              Navigator.pop(context);
              await supabase.auth.signOut();
            },
          ),
        ],
      );
}
