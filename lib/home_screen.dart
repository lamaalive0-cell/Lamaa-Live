import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'room_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            RoomsPage(userName: widget.userName),
            CategoriesPage(userName: widget.userName),
            GamesPage(userName: widget.userName),
            GiftsPage(userName: widget.userName),
            ProfileScreen(userName: widget.userName),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          border: Border(top: BorderSide(color: Color(0xFF2A2A35))),
        ),
        child: BottomNavigationBar(
          currentIndex: tab,
          onTap: (i) => setState(() => tab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF8B5CF6),
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'الغرف'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'الأقسام'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'الألعاب'),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'الهدايا'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}

// ============ الغرف ============
class RoomsPage extends StatefulWidget {
  final String userName;
  const RoomsPage({super.key, required this.userName});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> rooms = [];
  bool loading = true;
  String selectedCategory = 'الكل';

  final categories = const ['الكل', 'دردشة', 'موسيقى', 'ألعاب', 'مواهب', 'تعارف'];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    setState(() => loading = true);
    try {
      final data = await supabase.from('rooms').select().order('id', ascending: false);
      setState(() {
        rooms = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List<dynamic> get filteredRooms {
    if (selectedCategory == 'الكل') return rooms;
    return rooms.where((r) => (r['category'] ?? 'دردشة') == selectedCategory).toList();
  }

  Future<void> createRoom() async {
    final titleController = TextEditingController(text: 'غرفة ${widget.userName}');
    String category = 'دردشة';
    bool isVideo = true;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('🎥 إنشاء بث مباشر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'اسم الغرفة',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true, fillColor: const Color(0xFF12121A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                dropdownColor: const Color(0xFF1A1A24),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'القسم',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true, fillColor: const Color(0xFF12121A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: ['دردشة', 'موسيقى', 'ألعاب', 'مواهب', 'تعارف']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModalState(() => category = v!),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF12121A), borderRadius: BorderRadius.circular(14)),
                child: SwitchListTile(
                  value: isVideo,
                  activeColor: const Color(0xFF8B5CF6),
                  title: Text(isVideo ? '📹 بث فيديو + صوت' : '🎙️ صوت فقط'),
                  onChanged: (v) => setModalState(() => isVideo = v),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.live_tv, color: Colors.white),
                  label: const Text('بدء البث الآن', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context, {
                    'title': titleController.text.trim(),
                    'category': category,
                    'is_video': isVideo,
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || (result['title'] as String).isEmpty) return;

    try {
      final inserted = await supabase.from('rooms').insert({
        'title': result['title'],
        'host_id': '00000000-0000-0000-0000-000000000001',
        'category': result['category'],
        'is_video': result['is_video'],
      }).select().single();

      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(
        builder: (_) => RoomScreen(
          roomId: inserted['id'] as int,
          userName: widget.userName,
          isVideo: result['is_video'] == true,
          roomTitle: result['title'] as String,
        ),
      ));
      loadRooms();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredRooms;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createRoom,
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.videocam, color: Colors.white),
        label: const Text('بث جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('🎙️ Lamaa Live', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: loadRooms, icon: const Icon(Icons.refresh, color: Colors.white)),
              ],
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = categories[i];
                final selected = c == selectedCategory;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedCategory = c),
                  selectedColor: const Color(0xFF8B5CF6),
                  backgroundColor: const Color(0xFF1A1A24),
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey[400]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? const Center(child: Text('لا توجد غرف', style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final room = list[i];
                          final isVideo = room['is_video'] == true;
                          final colors = [
                            [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                            [const Color(0xFFF093FB), const Color(0xFFF5576C)],
                            [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
                            [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
                            [const Color(0xFFFA709A), const Color(0xFFFEE140)],
                            [const Color(0xFF30CFD0), const Color(0xFF330867)],
                          ];
                          final c = colors[i % colors.length];

                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(
                                builder: (_) => RoomScreen(
                                  roomId: room['id'] as int,
                                  userName: widget.userName,
                                  isVideo: isVideo,
                                  roomTitle: room['title'] ?? 'غرفة',
                                ),
                              ));
                              loadRooms();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(colors: c, begin: Alignment.topLeft, end: Alignment.bottomRight),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 10, right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                        Icon(Icons.circle, size: 8, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ]),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10, left: 10,
                                    child: Icon(isVideo ? Icons.videocam : Icons.mic, color: Colors.white70, size: 20),
                                  ),
                                  Positioned(
                                    bottom: 12, left: 12, right: 12,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(room['title'] ?? 'غرفة',
                                            maxLines: 2, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          const Icon(Icons.people, size: 12, color: Colors.white70),
                                          const SizedBox(width: 4),
                                          Text('${(room['listeners_count'] ?? 0)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                            child: Text(room['category'] ?? 'دردشة', style: const TextStyle(fontSize: 10, color: Colors.white)),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ============ الأقسام ============
class CategoriesPage extends StatelessWidget {
  final String userName;
  const CategoriesPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'دردشة', 'icon': '💬', 'color': const Color(0xFF3B82F6)},
      {'name': 'موسيقى', 'icon': '🎵', 'color': const Color(0xFFEC4899)},
      {'name': 'ألعاب', 'icon': '🎮', 'color': const Color(0xFFF59E0B)},
      {'name': 'مواهب', 'icon': '⭐', 'color': const Color(0xFFEAB308)},
      {'name': 'تعارف', 'icon': '💕', 'color': const Color(0xFFEF4444)},
      {'name': 'قرآن', 'icon': '📖', 'color': const Color(0xFF14B8A6)},
      {'name': 'شعر', 'icon': '✒️', 'color': const Color(0xFF8B5CF6)},
      {'name': 'كوميدي', 'icon': '😂', 'color': const Color(0xFFF97316)},
      {'name': 'رياضة', 'icon': '⚽', 'color': const Color(0xFF22C55E)},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('الأقسام', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📂 قسم ${item['name']} - افتح تبويب الغرف للفلترة'),
                  backgroundColor: item['color'] as Color,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [(item['color'] as Color).withOpacity(0.8), (item['color'] as Color).withOpacity(0.4)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['icon'] as String, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(item['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============ الألعاب ============
class GamesPage extends StatelessWidget {
  final String userName;
  const GamesPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'عجلة الحظ', 'emoji': '🎡', 'desc': 'اربح كوينز يوميًا', 'reward': '100-1000 💰'},
      {'name': 'روليت', 'emoji': '🎰', 'desc': 'لعبة الحظ السريعة', 'reward': 'x2 - x10'},
      {'name': 'لودو', 'emoji': '🎲', 'desc': 'العب مع الأصدقاء', 'reward': '500 💎'},
      {'name': 'تحدي الغرفة', 'emoji': '🏆', 'desc': 'تحديات مباشرة', 'reward': 'ألماس'},
      {'name': 'قرعة الكنز', 'emoji': '💎', 'desc': 'اسحب كنزك اليومي', 'reward': 'مجاني'},
      {'name': 'X.O', 'emoji': '❌', 'desc': 'إكس أو كلاسيكية', 'reward': '50 💰'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('الألعاب', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final g = games[i];
          return GestureDetector(
            onTap: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A24),
                title: Text('${g['emoji']} ${g['name']}'),
                content: Text('${g['desc']}\n\nالجائزة: ${g['reward']}\n\nستُفعل هذه اللعبة قريبًا داخل الغرف!'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))],
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [const Color(0xFF1A1A24), const Color(0xFF2A1E3F).withOpacity(0.6)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(g['emoji']!, style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(g['desc']!, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Text('🏆 ${g['reward']}', style: const TextStyle(fontSize: 11, color: Colors.amber)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_circle_fill, color: Color(0xFF8B5CF6), size: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============ الهدايا (30+ هدية) ============
class GiftsPage extends StatefulWidget {
  final String userName;
  const GiftsPage({super.key, required this.userName});

  @override
  State<GiftsPage> createState() => _GiftsPageState();
}

class _GiftsPageState extends State<GiftsPage> {
  String category = 'الكل';

  final allGifts = const [
    // رخيصة
    {'emoji': '🌹', 'name': 'وردة', 'price': 10, 'cat': 'رخيصة'},
    {'emoji': '🌺', 'name': 'زهرة', 'price': 15, 'cat': 'رخيصة'},
    {'emoji': '💐', 'name': 'باقة ورد', 'price': 25, 'cat': 'رخيصة'},
    {'emoji': '🍫', 'name': 'شوكولاتة', 'price': 30, 'cat': 'رخيصة'},
    {'emoji': '🎂', 'name': 'كيكة', 'price': 50, 'cat': 'رخيصة'},
    {'emoji': '🍦', 'name': 'آيسكريم', 'price': 40, 'cat': 'رخيصة'},
    // شعبية
    {'emoji': '💖', 'name': 'قلب', 'price': 100, 'cat': 'شعبية'},
    {'emoji': '💝', 'name': 'قلب هدية', 'price': 150, 'cat': 'شعبية'},
    {'emoji': '💎', 'name': 'ألماسة', 'price': 200, 'cat': 'شعبية'},
    {'emoji': '⭐', 'name': 'نجمة', 'price': 250, 'cat': 'شعبية'},
    {'emoji': '🎁', 'name': 'هدية', 'price': 180, 'cat': 'شعبية'},
    {'emoji': '🧸', 'name': 'دبدوب', 'price': 220, 'cat': 'شعبية'},
    // ملكية
    {'emoji': '👑', 'name': 'تاج', 'price': 500, 'cat': 'ملكية'},
    {'emoji': '💍', 'name': 'خاتم', 'price': 800, 'cat': 'ملكية'},
    {'emoji': '📿', 'name': 'قلادة', 'price': 700, 'cat': 'ملكية'},
    {'emoji': '🏆', 'name': 'كأس ذهبي', 'price': 1000, 'cat': 'ملكية'},
    {'emoji': '🥇', 'name': 'ميدالية', 'price': 600, 'cat': 'ملكية'},
    // فخمة
    {'emoji': '🚗', 'name': 'سيارة', 'price': 2000, 'cat': 'فخمة'},
    {'emoji': '🏎️', 'name': 'سيارة سباق', 'price': 3000, 'cat': 'فخمة'},
    {'emoji': '🛥️', 'name': 'يخت', 'price': 5000, 'cat': 'فخمة'},
    {'emoji': '✈️', 'name': 'طائرة', 'price': 4000, 'cat': 'فخمة'},
    {'emoji': '🚁', 'name': 'مروحية', 'price': 3500, 'cat': 'فخمة'},
    // أسطورية
    {'emoji': '🏰', 'name': 'قصر', 'price': 8000, 'cat': 'أسطورية'},
    {'emoji': '🚀', 'name': 'صاروخ', 'price': 10000, 'cat': 'أسطورية'},
    {'emoji': '🛸', 'name': 'سفينة فضاء', 'price': 15000, 'cat': 'أسطورية'},
    {'emoji': '🌋', 'name': 'بركان', 'price': 12000, 'cat': 'أسطورية'},
    {'emoji': '🐉', 'name': 'تنين', 'price': 20000, 'cat': 'أسطورية'},
    {'emoji': '🦄', 'name': 'يونيكورن', 'price': 25000, 'cat': 'أسطورية'},
    {'emoji': '🌟', 'name': 'نجم أسطوري', 'price': 30000, 'cat': 'أسطورية'},
    {'emoji': '👽', 'name': 'كائن فضائي', 'price': 18000, 'cat': 'أسطورية'},
  ];

  @override
  Widget build(BuildContext context) {
    final cats = ['الكل', 'رخيصة', 'شعبية', 'ملكية', 'فخمة', 'أسطورية'];
    final list = category == 'الكل' ? allGifts : allGifts.where((g) => g['cat'] == category).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('🎁 متجر الهدايا', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('رصيدك', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('0 كوينز', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text('شحن +', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = cats[i];
                final sel = c == category;
                return ChoiceChip(
                  label: Text(c),
                  selected: sel,
                  onSelected: (_) => setState(() => category = c),
                  selectedColor: const Color(0xFF8B5CF6),
                  backgroundColor: const Color(0xFF1A1A24),
                  labelStyle: TextStyle(color: sel ? Colors.white : Colors.grey[400]),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.8,
              ),
              itemBuilder: (context, i) {
                final g = list[i];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${g['emoji']} ${g['name']} - ${g['price']} كوينز')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1A1A24), const Color(0xFF2A1E3F).withOpacity(0.5)],
                      ),
                      border: Border.all(color: const Color(0xFF2F2F3C)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(g['emoji'] as String, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(g['name'] as String, style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text('${g['price']} 💰', style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
