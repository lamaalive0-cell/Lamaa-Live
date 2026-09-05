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

final supabase = Supabase.instance.client;class LamaaLiveApp extends StatelessWidget {
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
        colorScheme: const ColorScheme.dark(primary: Color(0xFFFFD700), surface: Color(0xFF1A1A22)),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A1A22), elevation: 0, centerTitle: true),
      ),
      home: const AuthGate(),
    );
  }
}class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) => supabase.auth.currentSession != null ? const MainNavigationScreen() : const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _signUp = false;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      if (_signUp) {
        await supabase.auth.signUp(email: _email.text.trim(), password: _password.text.trim(), data: {'username': _username.text.trim()});
      } else {
        await supabase.auth.signInWithPassword(email: _email.text.trim(), password: _password.text.trim());
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨ لمعة لايف ✨', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
            const SizedBox(height: 30),
            if (_signUp) TextField(controller: _username, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'الإيميل')),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة السر')),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : Text(_signUp ? 'إنشاء حساب' : 'دخول'),
            ),TextButton(onPressed: () => setState(() => _signUp = !_signUp), child: Text(_signUp ? 'دخول' : 'حساب جديد', style: const TextStyle(color: Color(0xFFFFD700)))),
          ],
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
        currentIndex: i,onTap: (v) => setState(() => i = v),
        backgroundColor: const Color(0xFF0F0F12),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
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

// 1️⃣ الشاشة الرئيسية (الغرف الصوتية)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final _roomTitle = TextEditingController();

  Future<void> _createRoom() async {
    final user = supabase.auth.currentUser;
    if (_roomTitle.text.isEmpty || user == null) return;
    final res = await supabase.from('rooms').insert({
      'title': _roomTitle.text.trim(),
      'host_id': user.id,
      'category': 'عام'
    }).select().single();
    
    _roomTitle.clear();
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(roomData: res)));
    }
  }void _showCreateRoomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('إنشاء غرفة جديدة 🎙️', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _roomTitle, decoration: const InputDecoration(labelText: 'عنوان الغرفة')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _createRoom, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black), child: const Text('بدء البث')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✨ لمعة لايف ✨'), actions: [IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700)), onPressed: _showCreateRoomSheet)]),
      body: StreamBuilder(
        stream: supabase.from('rooms').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          final rooms = snapshot.data as List;
          if (rooms.isEmpty) {
            return const Center(child: Text('لا توجد غرف مفتوحة حالياً.\nاضغط على + في الأعلى لإنشاء أول غرفة!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: rooms.length,
            itemBuilder: (context, idx) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(roomData: rooms[idx]))),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 25, backgroundColor: Color(0xFF0F0F12), child: Icon(Icons.mic, color: Color(0xFFFFD700))),
                    const SizedBox(height: 10),
                    Text(rooms[idx]['title'] ?? 'غرفة لمعة', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('🔴 بث حي - اضغط للدخول',style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// داخل الغرفة الصوتية الحقيقية (الكراسي + الشات + الهدايا)
class RoomDetailScreen extends StatefulWidget {
  final Map<String, dynamic> roomData;
  const RoomDetailScreen({super.key, required this.roomData});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _msgController = TextEditingController();
  final user = supabase.auth.currentUser;

  Future<void> _toggleSeat(int seatIndex, dynamic currentParticipant) async {
    final roomId = widget.roomData['id'];
    if (currentParticipant != null) {
      if (currentParticipant['user_id'] == user?.id) {
        await supabase.from('room_participants').delete().eq('room_id', roomId).eq('user_id', user!.id);
      } else {
        _showGiftStore(currentParticipant['user_id'], 'عضو');
      }
    } else {
      try {
        await supabase.from('room_participants').upsert({'room_id': roomId, 'user_id': user!.id, 'seat_index': seatIndex});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكراسي محجوزة أو أنك جالس بالداخل')));
      }
    }
  }Future<void> _sendMessage() async {
    if (_msgController.text.trim().isEmpty || user == null) return;
    final profile = await supabase.from('profiles').select('username').eq('id', user!.id).maybeSingle();
    final name = profile?['username'] ?? 'مستخدم';
    
    await supabase.from('room_messages').insert({
      'room_id': widget.roomData['id'],
      'user_id': user!.id,
      'sender_name': name,
      'message': _msgController.text.trim(),
    });
    _msgController.clear();
  }

  void _showGiftStore(String targetUserId, String targetName) {
    final gifts = [
      {'name': '🌹 وردة', 'price': 10},
      {'name': '💖 قلب لمعة', 'price': 50},
      {'name': '☕ قهوة', 'price': 200},
      {'name': '🏎️ فراري', 'price': 1000},
      {'name': '🏰 قصر لمعة', 'price': 5000},
      {'name': '👑 تاج الملك', 'price': 10000},
    ];showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('إرسال هدية إلى: $targetName 🎁', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: gifts.length,
              itemBuilder: (context, idx) => GestureDetector(
                onTap: () => _sendGift(targetUserId, targetName, gifts[idx]['name'] as String, gifts[idx]['price'] as int),
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF0F0F12), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,children: [
                      Text(gifts[idx]['name'].toString().split(' ')[0], style: const TextStyle(fontSize: 28)),
                      Text(gifts[idx]['name'].toString().split(' ').sublist(1).join(' '), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('🪙 ${gifts[idx]['price']}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendGift(String targetUserId, String targetName, String giftName, int price) async {
    Navigator.pop(context);try {
      final senderProfile = await supabase.from('profiles').select('gold_balance, username').eq('id', user!.id).single();
      int currentGold = senderProfile['gold_balance'] ?? 0;
      String senderName = senderProfile['username'] ?? 'مستخدم';

      if (currentGold < price) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رصيدك غير كافٍ من الذهب')));
        return;
      }

      await supabase.from('profiles').update({'gold_balance': currentGold - price}).eq('id', user!.id);
      final receiverProfile = await supabase.from('profiles').select('points_balance').eq('id', targetUserId).single();
      int receiverPoints = receiverProfile['points_balance'] ?? 0;
      await supabase.from('profiles').update({'points_balance': receiverPoints + price}).eq('id', targetUserId);await supabase.from('room_messages').insert({
        'room_id': widget.roomData['id'],
        'user_id': user!.id,
        'sender_name': '🎁 إعلان هدية',
        'message': 'قام $senderName بإرسال [$giftName] بقيمة $price ذهب! 🎉✨',
        'is_gift_banner': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال $giftName بنجاح! 🚀'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الإرسال: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomId = widget.roomData['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomData['title'] ?? 'الغرفة الصوتية'),
        actions: [IconButton(icon: const Icon(Icons.exit_to_app, color: Colors.redAccent), onPressed: () => Navigator.pop(context))],
      ),body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF14141A),
            child: StreamBuilder(
              stream: supabase.from('room_participants').stream(primaryKey: ['id']).eq('room_id', roomId),
              builder: (context, snapshot) {
                final participants = snapshot.data as List? ?? [];
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: 8,
                  itemBuilder: (context, seatIdx) {
                    final participant = participants.firstWhere((p) => p['seat_index'] == seatIdx, orElse: () => null);
                    final isOccupied = participant !=null;
                    final isMe = isOccupied && participant['user_id'] == user?.id;

                    return GestureDetector(
                      onTap: () => _toggleSeat(seatIdx, participant),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFFFD700).withOpacity(0.2) : const Color(0xFF1A1A22),
                          shape: BoxShape.circle,
                          border: Border.all(color: isOccupied ? const Color(0xFFFFD700) : Colors.white12, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isOccupied ? Icons.mic : Icons.add, color: isOccupied ? const Color(0xFFFFD700) : Colors.white38, size: 22),
                            Text(isOccupied ? (isMe ? 'أنت' : 'مايك ${seatIdx + 1}') : 'كرسي ${seatIdx + 1}', style: TextStyle(fontSize: 9, color: isOccupied ? Colors.white : Colors.white38)),],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          Expanded(
            child: StreamBuilder(
              stream: supabase.from('room_messages').stream(primaryKey: ['id']).eq('room_id', roomId).order('created_at', ascending: true),
              builder: (context, snapshot) {
                final messages = snapshot.data as List? ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, idx) {
                    final msg = messages[idx];
                    final isBanner = msg['is_gift_banner'] ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isBanner ? const Color(0xFFFFD700).withOpacity(0.15) : const Color(0xFF1A1A22),
                        borderRadius: BorderRadius.circular(10),
                        border: isBanner ? Border.all(color: const Color(0xFFFFD700)) : null,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '${msg['sender_name']}: ', style: TextStyle(fontWeight: FontWeight.bold, color: isBanner ? const Color(0xFFFFD700) : Colors.cyanAccent, fontSize: 12)),
                            TextSpan(text: msg['message'], style: TextStyle(color: isBanner ? const Color(0xFFFFD700) : Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF1A1A22),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'اكتب رسالة في الغرفة...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 12)),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFFFFD700)), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 2️⃣ قسم الألعاب الشغال بالكامل (Greedy Cat + عجلة الحظ)
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @overrideWidget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 ساحة الألعاب التفاعلية')),
      body: GridView(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
        children: [
          _gameCard(context, 'Greedy Cat 🐱', 'الخضار واللحوم (x45)', '🐱', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GreedyCatGameScreen()))),
          _gameCard(context, 'عجلة الحظ 🎡', 'مضاعفات حتى x50', '🎡', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WheelGameScreen()))),
          _gameCard(context, 'لودو 🎲', 'لعبة الطاولة (قريباً)', '🎲', () => _showRule(context, 'لودو')),
          _gameCard(context, 'بوكر 🃏', 'تكساس هولدم (قريباً)', '🃏', () => _showRule(context, 'بوكر')),
        ],
      ),
    );
  }

  static Widget _gameCard(BuildContext ctx, String title, String sub, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15)),
            Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  static void _showRule(BuildContext ctx, String name) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('لعبة $name ستتوفر في التحديث القادم!')));
  }
}

// لعبة Greedy Cat الحقيقية (الرهان والربح بالذهب)
class GreedyCatGameScreen extends StatefulWidget {
  const GreedyCatGameScreen({super.key});
  @overrideState<GreedyCatGameScreen> createState() => _GreedyCatGameScreenState();
}

class _GreedyCatGameScreenState extends State<GreedyCatGameScreen> {
  final user = supabase.auth.currentUser;
  int _betAmount = 100;
  String _selectedOption = 'خضار 🥬 (x5)';
  bool _isPlaying = false;

  final Map<String, int> options = {
    'خضار 🥬 (x5)': 5,
    'لحم عادي 🥩 (x10)': 10,
    'مشوي 🍖 (x15)': 15,
    'دجاج 🍗 (x25)': 25,
    'وجبة الملك 👑 (x45)': 45,
  };

  Future<void> _play() async {
    if (user == null) return;
    setState(() => _isPlaying = true);

    try {
      final profile = await supabase.from('profiles').select('gold_balance').eq('id', user!.id).single();
      int currentGold = profile['gold_balance'] ?? 0;

      if (currentGold < _betAmount) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رصيدك لا يكفي للرهان!')));
        setState(() => _isPlaying = false);return;
      }

      // خصم قيمة الرهان
      await supabase.from('profiles').update({'gold_balance': currentGold - _betAmount}).eq('id', user!.id);

      // محاكاة نتيجة عشوائية
      await Future.delayed(const Duration(seconds: 2));
      final rand = Random().nextInt(100);
      bool isWin = false;
      int multiplier = options[_selectedOption]!;

      if (multiplier == 5 && rand < 40) isWin = true; // 40% فرصة الخضار
      if (multiplier == 10 && rand < 20) isWin = true;
      if (multiplier == 15 && rand < 12) isWin = true;
      if (multiplier == 25 && rand < 6) isWin = true;
      if (multiplier == 45 && rand < 2) isWin = true;

      if (isWin) {int winAmount = _betAmount * multiplier;
        await supabase.from('profiles').update({'gold_balance': (currentGold - _betAmount) + winAmount}).eq('id', user!.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 فزت بـ $winAmount ذهب! (مضاعف x$multiplier)'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('😿 للأسف لم تفز هذه المرة، حاول مجدداً!'), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🐱 Greedy Cat (الخضار واللحوم)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.pets, size: 80, color: Color(0xFFFFD700)),const SizedBox(height: 10),
            const Text('اختر الوجبة وراهن بالذهب:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedOption,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A22),
              items: options.keys.map((String key) => DropdownMenuItem(value: key, child: Text(key, style: const TextStyle(color: Color(0xFFFFD700))))).toList(),
              onChanged: (val) => setState(() => _selectedOption = val!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [100, 500, 1000, 5000].map((amt) => ChoiceChip(
                label: Text('$amt 🪙'),
                selected: _betAmount == amt,
                selectedColor: const Color(0xFFFFD700),
                onSelected: (_) => setState(() => _betAmount = amt),
              )).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: _isPlaying ? null : _play,
              child: _isPlaying ? const CircularProgressIndicator(color: Colors.black) : const Text('🎲 ابدأ الرهان واللعب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// لعبة عجلة الحظ
class WheelGameScreen extends StatefulWidget {
  const WheelGameScreen({super.key});
  @override
  State<WheelGameScreen> createState() => _WheelGameScreenState();
}

class _WheelGameScreenState extends State<WheelGameScreen> {
  final user = supabase.auth.currentUser;
  bool _spinning = false;

  Future<void> _spin() async {
    if (user == null) return;
    setState(() => _spinning = true);
    try {final profile = await supabase.from('profiles').select('gold_balance').eq('id', user!.id).single();
      int gold = profile['gold_balance'] ?? 0;

      if (gold < 100) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يحتاج التدوير إلى 100 ذهب!')));
        setState(() => _spinning = false);
        return;
      }

      await supabase.from('profiles').update({'gold_balance': gold - 100}).eq('id', user!.id);
      await Future.delayed(const Duration(seconds: 2));

      final mults = [0, 2, 5, 10, 50];
      final winMult = mults[Random().nextInt(mults.length)];

      if (winMult > 0) {
        int prize = 100 * winMult;
        await supabase.from('profiles').update({'gold_balance': (gold - 100) + prize}).eq('id', user!.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 فزت بـ $prize ذهب! (x$winMult)'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💔 حظ أوفر، خرجت العجلة فارغة!'), backgroundColor: Colors.redAccent));backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _spinning = false);
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
            const Icon(Icons.blur_circular, size: 120, color: Color(0xFFFFD700)),
            const SizedBox(height: 20),
            const Text('تكلفة التدوير: 100 🪙', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: _spinning ? null : _spin,
              child: _spinning ? const CircularProgressIndicator() : const Text('🎡 أدر العجلة الآن!', style: TextStyle(fontWeight: FontWeight.bold)),),
          ],
        ),
      ),
    );
  }
}

// 3️⃣ قسم المنشورات الحقيقي
class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});
  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  final _postController = TextEditingController();

  Future<void> _addPost() async {
    final user = supabase.auth.currentUser;
    if (_postController.text.trim().isEmpty || user == null) return;
    final profile = await supabase.from('profiles').select('username').eq('id', user.id).maybeSingle();

    await supabase.from('moments').insert({
      'user_id': user.id,
      'author_name': profile?['username'] ?? 'مستخدم لمعة',
      'content': _postController.text.trim(),
    });

    _postController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('نشر لحظة جديدة 📝', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _postController, maxLines: 3, decoration: const InputDecoration(hintText: 'ماذا يخطر في بالك؟')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _addPost, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black), child: const Text('نشر المنشور')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 يوميات المنشورات'), actions: [IconButton(icon: const Icon(Icons.edit, color: Color(0xFFFFD700)), onPressed: _showAddPostSheet)]),
      body: StreamBuilder(
        stream: supabase.from('moments').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          final posts = snapshot.data as List;
          if (posts.isEmpty) return const Center(child: Text('لا توجد منشورات بعد.\nاضغط على القلم في الأعلى لتكون أول من ينشر!'));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,itemBuilder: (context, idx) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, color: Colors.black)),
                      const SizedBox(width: 10),
                      Text(posts[idx]['author_name'] ?? 'مستخدم لمعة', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(posts[idx]['content'] ?? ''),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget { const MessagesScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('💬 الرسائل')), body: const Center(child: Text('قائمة المحادثات الخاصة والتطوير مستمر!'))); }

// 4️⃣ قسم حسابي التفاعلي الشامل (جميع الأزرار شغالة بنوافذ حقيقية)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final res = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    if (mounted) setState(() { data = res; loading = false; });
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        title: Text(title, style: const TextStyle(color: Color(0xFFFFD700))),content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً', style: TextStyle(color: Color(0xFFFFD700))))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final gold = data?['gold_balance'] ?? 10000;
    final points = data?['points_balance'] ?? 0;
    final level = data?['user_level'] ?? 1;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي الشخصي')),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Center(child: CircleAvatar(radius: 50, backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, size: 60, color: Colors.black))),
                const SizedBox(height: 12),
                Center(child: Text(data?['username'] ?? user?.email?.split('@').first ?? 'مستخدم', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),Center(child: Text(user?.email ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12))),
                const SizedBox(height: 24),
                
                // كرت المحفظة التراكمية
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
                const SizedBox(height: 24),

                // جميع الأزرار تفاعلية بنوافذ حقيقية
                _tile(Icons.star, 'المستوى الحالي','Lv.$level (ملك لمعة)', () => _showInfoDialog('المستوى الحالي', 'أنت في المستوى $level.\nترتفع مستوياتك بزيادة النشاط وإرسال الهدايا والتفاعل بالغرف!')),
                _tile(Icons.workspace_premium, 'عضوية VIP', '4 مستويات', () => _showInfoDialog('عضوية VIP', 'مستويات VIP المتاحة:\n• VIP 1: إطار برونزي + 100 ذهب يومياً\n• VIP 2: إطار فضي + 300 ذهب يومياً\n• VIP 3: إطار ذهبي + 800 ذهب يومياً\n• VIP 4 👑: أسطوري + 2000 ذهب يومياً')),
                _tile(Icons.apartment, 'نظام الوكالة', 'لمعة ستارز', () => _showInfoDialog('الوكالة', 'نسب أرباح الوكلاء:\n• برونزي (50 عضو): 10%\n• فضي (150 عضو): 13%\n• ذهبي (300 عضو): 16%\n• ألماسي (500 عضو): 20%')),
                _tile(Icons.card_giftcard, 'صندوق الهدايا', '700 هدية', () => _showInfoDialog('صندوق الهدايا', 'يحتوي على كافة الهدايا التي استلمتها من أصدقائك داخل الغرف الصوتية!')),
                _tile(Icons.history, 'سجل المعاملات', 'عرض العمليات', () => _showInfoDialog('سجل المعاملات', 'رصيدك الحالي: $gold ذهب.\nنقاط الهدايا المستقبلة: $points نقطة.')),
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

  Widget _tile(IconData i, String t, String s, VoidCallback onTap) => ListTile(
    leading: Icon(i, color: const Color(0xFFFFD700)),
    title: Text(t),
    subtitle: Text(s, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    onTap: onTap,
  );
}
