import 'dart:math';
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
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          surface: Color(0xFF1A1A22),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A22),
          centerTitle: true,
          elevation: 0,
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
      builder: (context, snapshot) {
        if (supabase.auth.currentSession != null) {
          return const MainTabs();
        }
        return const AuthPage();
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final name = TextEditingController();
  bool signUp = false;
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      if (signUp) {
        await supabase.auth.signUp(
          email: email.text.trim(),
          password: pass.text.trim(),
          data: {'username': name.text.trim()},
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: email.text.trim(),
          password: pass.text.trim(),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨ لمعة لايف ✨', style: TextStyle(fontSize: 28, color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (signUp) TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'الإيميل')),
            TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة السر')),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: loading ? null : submit,
              child: loading ? const CircularProgressIndicator(color: Colors.black) : Text(signUp ? 'إنشاء حساب' : 'دخول'),
            ),
            TextButton(
              onPressed: () => setState(() => signUp = !signUp),
              child: Text(signUp ? 'لديك حساب؟ دخول' : 'حساب جديد', style: const TextStyle(color: Color(0xFFFFD700))),
            ),
          ],
        ),
      ),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int i = 0;
  final pages = const [HomePage(), GamesPage(), MomentsPage(), InboxPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: (v) => setState(() => i = v),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F0F12),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'الألعاب'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion), label: 'يومياتي'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الرسائل'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ================= 1. الرئيسية والغرف الصوتية =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final titleC = TextEditingController();

  Future<void> createRoom() async {
    final u = supabase.auth.currentUser;
    if (u == null || titleC.text.trim().isEmpty) return;
    final row = await supabase.from('rooms').insert({
      'title': titleC.text.trim(),
      'host_id': u.id,
      'category': 'عام',
    }).select().single();
    titleC.clear();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage(room: row)));
  }

  void openCreate() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A22),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('إنشاء غرفة جديدة 🎙️', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: titleC, decoration: const InputDecoration(labelText: 'عنوان الغرفة')),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
            onPressed: createRoom,
            child: const Text('بدء البث'),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ لمعة لايف ✨'),
        actions: [
          IconButton(onPressed: openCreate, icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700))),
        ],
      ),
      body: StreamBuilder(
        stream: supabase.from('rooms').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }
          final rooms = (snap.data as List?) ?? [];
          if (rooms.isEmpty) {
            return const Center(
              child: Text('لا توجد غرف مفتوحة حالياً.\nاضغط + في الأعلى لإنشاء غرفتك!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final r = rooms[i] as Map;
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage(room: r))),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A22),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.mic, color: Color(0xFFFFD700), size: 36),
                    const SizedBox(height: 8),
                    Text('${r['title'] ?? 'غرفة لمعة'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('🔴 بث حي - اضغط للدخول', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= داخل الغرفة =================
class RoomPage extends StatefulWidget {
  final Map room;
  const RoomPage({super.key, required this.room});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final msgC = TextEditingController();
  List seats = [];
  List messages = [];

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    final rid = widget.room['id'];
    try {
      final s = await supabase.from('room_participants').select().eq('room_id', rid);
      final m = await supabase.from('room_messages').select().eq('room_id', rid).order('created_at');
      if (mounted) setState(() { seats = s; messages = m; });
    } catch (_) {}
  }

  Future<void> sit(int index) async {
    final u = supabase.auth.currentUser;
    if (u == null) return;
    final rid = widget.room['id'];
    final mine = seats.where((e) => e['user_id'] == u.id).toList();
    final taken = seats.where((e) => e['seat_index'] == index).toList();

    if (mine.isNotEmpty) {
      await supabase.from('room_participants').delete().eq('room_id', rid).eq('user_id', u.id);
    } else if (taken.isEmpty) {
      await supabase.from('room_participants').insert({
        'room_id': rid,
        'user_id': u.id,
        'seat_index': index,
      });
    } else {
      openGifts(taken.first['user_id'].toString());
      return;
    }
    await loadAll();
  }

  Future<void> sendMsg() async {
    final u = supabase.auth.currentUser;
    if (u == null || msgC.text.trim().isEmpty) return;
    final p = await supabase.from('profiles').select('username').eq('id', u.id).maybeSingle();
    await supabase.from('room_messages').insert({
      'room_id': widget.room['id'],
      'user_id': u.id,
      'sender_name': p?['username'] ?? 'مستخدم',
      'message': msgC.text.trim(),
    });
    msgC.clear();
    await loadAll();
  }

  void openGifts(String targetId) {
    final gifts = [
      ['🌹 وردة', 10],
      ['💖 قلب', 50],
      ['🏎️ فراري', 1000],
      ['🏰 قصر', 5000],
      ['👑 تاج الملك', 10000],
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: gifts.map((g) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
              onPressed: () async {
                Navigator.pop(context);
                await sendGift(targetId, g[0] as String, g[1] as int);
              },
              child: Text('${g[0]} - ${g[1]}🪙'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> sendGift(String targetId, String gift, int price) async {
    final u = supabase.auth.currentUser;
    if (u == null) return;
    final me = await supabase.from('profiles').select('gold_balance, username').eq('id', u.id).single();
    final gold = (me['gold_balance'] ?? 0) as int;
    if (gold < price) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الذهب غير كافٍ! قم بالشحن')));
      }
      return;
    }
    await supabase.from('profiles').update({'gold_balance': gold - price}).eq('id', u.id);
    final recv = await supabase.from('profiles').select('points_balance').eq('id', targetId).maybeSingle();
    final pts = (recv?['points_balance'] ?? 0) as int;
    await supabase.from('profiles').update({'points_balance': pts + price}).eq('id', targetId);
    await supabase.from('room_messages').insert({
      'room_id': widget.room['id'],
      'user_id': u.id,
      'sender_name': '🎁 إعلان هدية',
      'message': '${me['username']} أرسل $gift بقيمة $price 🪙',
      'is_gift_banner': true,
    });
    await loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final u = supabase.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.room['title'] ?? 'الغرفة الصوتية'}')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemBuilder: (context, i) {
              final list = seats.where((e) => e['seat_index'] == i).toList();
              final occ = list.isNotEmpty;
              final me = occ && list.first['user_id'] == u?.id;
              return InkWell(
                onTap: () => sit(i),
                child: CircleAvatar(
                  backgroundColor: me ? const Color(0xFFFFD700) : const Color(0xFF1A1A22),
                  child: Text(occ ? (me ? 'أنت' : '🎤') : '${i + 1}',
                      style: TextStyle(color: me ? Colors.black : Colors.white, fontSize: 12)),
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              final isBanner = m['is_gift_banner'] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${m['sender_name']}: ${m['message']}',
                    style: TextStyle(color: isBanner ? const Color(0xFFFFD700) : Colors.white, fontWeight: isBanner ? FontWeight.bold : FontWeight.normal)),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF1A1A22),
          child: Row(children: [
            Expanded(child: TextField(controller: msgC, decoration: const InputDecoration(hintText: 'اكتب رسالة...', border: InputBorder.none))),
            IconButton(onPressed: sendMsg, icon: const Icon(Icons.send, color: Color(0xFFFFD700))),
            IconButton(onPressed: loadAll, icon: const Icon(Icons.refresh, color: Colors.white70)),
          ]),
        ),
      ]),
    );
  }
}

// ================= 2. الألعاب =================
class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 الألعاب التفاعلية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _gameCard(context, '🐱 Greedy Cat (الخضار واللحوم)', 'مضاعفات حتى x45', const GreedyPage()),
          const SizedBox(height: 12),
          _gameCard(context, '🎡 عجلة الحظ', 'مضاعفات حتى x50', const WheelPage()),
        ],
      ),
    );
  }

  Widget _gameCard(BuildContext context, String title, String sub, Widget page) {
    return Card(
      color: const Color(0xFF1A1A22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3))),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.play_arrow, color: Color(0xFFFFD700)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

class GreedyPage extends StatefulWidget {
  const GreedyPage({super.key});

  @override
  State<GreedyPage> createState() => _GreedyPageState();
}

class _GreedyPageState extends State<GreedyPage> {
  int bet = 100;
  int mult = 5;
  bool playing = false;

  Future<void> play() async {
    final u = supabase.auth.currentUser;
    if (u == null) return;
    setState(() => playing = true);
    try {
      final p = await supabase.from('profiles').select('gold_balance').eq('id', u.id).single();
      final gold = (p['gold_balance'] ?? 0) as int;
      if (gold < bet) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الذهب غير كافٍ!')));
        return;
      }
      await supabase.from('profiles').update({'gold_balance': gold - bet}).eq('id', u.id);
      await Future.delayed(const Duration(seconds: 1));
      final win = Random().nextInt(100) < (mult == 5 ? 35 : mult == 10 ? 18 : 5);
      if (win) {
        final prize = bet * mult;
        await supabase.from('profiles').update({'gold_balance': gold - bet + prize}).eq('id', u.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 فزت بـ $prize ذهب!'), backgroundColor: Colors.green));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('😿 لم تفز هذه المرة'), backgroundColor: Colors.redAccent));
        }
      }
    } finally {
      if (mounted) setState(() => playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🐱 Greedy Cat')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text('اختر المضاعف والرهان:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [5, 10, 25, 45].map((m) {
            return ChoiceChip(
              label: Text('x$m'),
              selected: mult == m,
              selectedColor: const Color(0xFFFFD700),
              onSelected: (_) => setState(() => mult = m),
            );
          }).toList()),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [100, 500, 1000].map((b) {
            return ChoiceChip(
              label: Text('$b🪙'),
              selected: bet == b,
              selectedColor: const Color(0xFFFFD700),
              onSelected: (_) => setState(() => bet =
);
          }).toList()),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 48)),
            onPressed: playing ? null : play,
            child: Text(playing ? 'جاري اللعب...' : '🎲 ابدأ الرهان'),
          ),
        ]),
      ),
    );
  }
}

class WheelPage extends StatefulWidget {
  const WheelPage({super.key});
  @override
  State<WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage> {
  bool spinning = false;

  Future<void> spin() async {
    final u = supabase.auth.currentUser;
    if (u == null) return;
    setState(() => spinning = true);
    try {
      final p = await supabase.from('profiles').select('gold_balance').eq('id', u.id).single();
      final gold = (p['gold_balance'] ?? 0) as int;
      if (gold < 100) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تحتاج 100 ذهب للتدوير!')));
        return;
      }

supabase.from('profiles').update({'gold_balance': gold - 100}).eq('id', u.id);
      await Future.delayed(const Duration(seconds: 1));
      final m = [0, 2, 5, 10][Random().nextInt(4)];
      if (m > 0) {
        final prize = 100 * m;
        await supabase.from('profiles').update({'gold_balance': gold - 100 + prize}).eq('id', u.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 فزت بـ $prize ذهب! (x$m)'), backgroundColor: Colors.green));
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💔 حظ أوفر'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => spinning = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎡 عجلة الحظ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.blur_circular, size: 100, color: Color(0xFFFFD700)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              onPressed: spinning ? null : spin,
              child: Text(spinning ? 'تدور...' : '🎡 أدِر العجلة بـ 100🪙'),
            ),
          ],
        ),
      ),
    );
  }
}
class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  State<MomentsPage> createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  final c = TextEditingController();
  List posts = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final res = await supabase.from('moments').select().order('created_at', ascending: false);
      if (mounted) setState(() => posts = res);
    } catch (_) {
      if (mounted) setState(() => posts = []);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 يومياتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFFFD700)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1A1A22),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(controller: c, decoration: const InputDecoration(hintText: 'اكتب منشورك هنا...')),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                      onPressed: add,
                      child: const Text('نشر الآن'),
                    ),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
body: RefreshIndicator(
        onRefresh: load,
        child: posts.isEmpty
            ? ListView(children: const [SizedBox(height: 100), Center(child: Text('لا توجد منشورات بعد، اضغط القلم لنشر أول منشور!'))])
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: posts.length,
                itemBuilder: (context, i) {
                  final p = posts[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p['author_name']}', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${p['content']}'),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}




@override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final u = supabase.auth.currentUser;
    if (u == null) return;
    final row = await supabase.from('profiles').select().eq('id', u.id).maybeSingle();
    if (mounted) setState(() => data = row);
  }

  void info(String t, String b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        title: Text(t, style: const TextStyle(color: Color(0xFFFFD700))),
        content: Text(b),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً', style: TextStyle(color: Color(0xFFFFD700))))],
      ),
    );
  }
@override
  Widget build(BuildContext context) {
    final u = supabase.auth.currentUser;
    final gold = data?['gold_balance'] ?? 10000;
    final points = data?['points_balance'] ?? 0;
    final level = data?['user_level'] ?? 1;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي الشخصي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: CircleAvatar(radius: 40, backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, color: Colors.black, size: 40))),
          const SizedBox(height: 8),
          Center(child: Text('${data?['username'] ?? u?.email?.split('@').first ?? 'مستخدم'}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF1A1A22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('🪙 الذهب: $gold', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                  Text('💎 النقاط: $points', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.star, color: Color(0xFFFFD700)),
            title: const Text('المستوى الحالي'),
            subtitle: Text('Lv.$level (ملك لمعة)'),
            onTap: () => info('المستوى الحالي', 'مستواك الحالي $level — يزيد بالنشاط والهدايا!'),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            title: const Text('عضوية VIP'),
            subtitle: const Text('عرض المستويات الـ 4'),
            onTap: () => info('عضوية VIP', 'مستويات VIP:\n• VIP 1: 4.99\$\n• VIP 2: 9.99\$\n• VIP 3: 19.99\$\n• VIP 4 👑: 49.99\$'),
          ),
          ListTile(
            leading: const Icon(Icons.apartment, color: Color(0xFFFFD700)),
            title: const Text('نظام الوكالة'),
            subtitle: const Text('عرض التفاصيل والعمولات'),
            onTap: () => info('الوكالة', 'عمولات الوكلاء من 10% إلى 20% حسب عدد الأعضاء والأرباح!'),
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: Color(0xFFFFD700)),
            title: const Text('صندوق الهدايا'),
            subtitle: const Text('700 هدية تفاعلية'),
            onTap: () => info('الهدايا', 'رصيد نقاطك الحالي: $points نقطة مجمعة من الهدايا.'),
          ),
const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
            onTap: () => supabase.auth.signOut(),
          ),
        ],
      ),
    );
  }
}
