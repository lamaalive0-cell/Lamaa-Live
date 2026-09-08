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
            CategoriesPage(onCategorySelected: (c) {
              setState(() => tab = 0);
            }),
            const GamesPage(),
            const GiftsPage(),
            ProfileScreen(userName: widget.userName),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) => setState(() => tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF12121A),
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'الغرف'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'الأقسام'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'الألعاب'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'الهدايا'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class RoomsPage extends StatefulWidget {
  final String userName;
  const RoomsPage({super.key, required this.userName});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final supabase = Supabase.instance.client;
  final searchController = TextEditingController();

  List<dynamic> rooms = [];
  bool loading = true;
  String? errorText;
  String selectedCategory = 'الكل';

  final categories = const ['الكل', 'دردشة', 'موسيقى', 'ألعاب', 'مواهب', 'تعارف'];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    setState(() {
      loading = true;
      errorText = null;
    });
    try {
      final data = await supabase.from('rooms').select().order('id', ascending: false);
      setState(() {
        rooms = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorText = e.toString();
      });
    }
  }

  List<dynamic> get filteredRooms {
    final q = searchController.text.trim();
    return rooms.where((r) {
      final cat = (r['category'] ?? 'دردشة').toString();
      final title = (r['title'] ?? '').toString();
      final byCat = selectedCategory == 'الكل' || cat == selectedCategory;
      final bySearch = q.isEmpty || title.contains(q);
      return byCat && bySearch;
    }).toList();
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('إنشاء بث مباشر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _field('اسم الغرفة'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    dropdownColor: const Color(0xFF1A1A24),
                    style: const TextStyle(color: Colors.white),
                    decoration: _field('القسم'),
                    items: const [
                      DropdownMenuItem(value: 'دردشة', child: Text('دردشة')),
                      DropdownMenuItem(value: 'موسيقى', child: Text('موسيقى')),
                      DropdownMenuItem(value: 'ألعاب', child: Text('ألعاب')),
                      DropdownMenuItem(value: 'مواهب', child: Text('مواهب')),
                      DropdownMenuItem(value: 'تعارف', child: Text('تعارف')),
                    ],
                    onChanged: (v) => setModalState(() => category = v ?? 'دردشة'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: isVideo,
                    activeColor: const Color(0xFF8B5CF6),
                    title: Text(isVideo ? 'فيديو + صوت' : 'صوت فقط'),
                    onChanged: (v) => setModalState(() => isVideo = v),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'title': titleController.text.trim(),
                          'category': category,
                          'is_video': isVideo,
                        });
                      },
                      child: const Text('بدء البث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    final title = (result['title'] as String?) ?? '';
    if (title.isEmpty) return;

    try {
      final userId = supabase.auth.currentUser?.id;
      final inserted = await supabase.from('rooms').insert({
        'title': title,
        'host_id': userId,
        'category': result['category'],
        'is_video': result['is_video'],
      }).select().single();

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomScreen(
            roomId: inserted['id'] as int,
            userName: widget.userName,
            isVideo: result['is_video'] == true,
            roomTitle: title,
          ),
        ),
      );
      loadRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء الغرفة: $e')),
      );
    }
  }

  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF12121A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('الغرف المباشرة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: loadRooms, icon: const Icon(Icons.refresh)),
              ],
            ),
          ),

          // بحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن غرفة...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // أقسام
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
          const SizedBox(height: 10),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : errorText != null
                    ? Center(child: Text(errorText!, style: const TextStyle(color: Colors.redAccent)))
                    : list.isEmpty
                        ? const Center(child: Text('لا توجد غرف', style: TextStyle(color: Colors.grey)))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                            itemCount: list.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                            itemBuilder: (context, i) {
                              final room = list[i];
                              final isVideo = room['is_video'] == true;
                              final gradients = [
                                const [Color(0xFF667EEA), Color(0xFF764BA2)],
                                const [Color(0xFFF093FB), Color(0xFFF5576C)],
                                const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                                const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                                const [Color(0xFFFA709A), Color(0xFFFEE140)],
                              ];
                              final g = gradients[i % gradients.length];

                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RoomScreen(
                                        roomId: room['id'] as int,
                                        userName: widget.userName,
                                        isVideo: isVideo,
                                        roomTitle: (room['title'] ?? 'غرفة').toString(),
                                      ),
                                    ),
                                  );
                                  loadRooms();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: g,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Icon(isVideo ? Icons.videocam : Icons.mic, color: Colors.white70, size: 18),
                                      ),
                                      Positioned(
                                        left: 12,
                                        right: 12,
                                        bottom: 12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (room['title'] ?? 'غرفة').toString(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.people, size: 14, color: Colors.white70),
                                                const SizedBox(width: 4),
                                                Text('${room['listeners_count'] ?? 0}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black26,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    (room['category'] ?? 'دردشة').toString(),
                                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                                  ),
                                                ),
                                              ],
                                            ),
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

class CategoriesPage extends StatelessWidget {
  final void Function(String category)? onCategorySelected;
  const CategoriesPage({super.key, this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'دردشة', 'icon': '💬', 'color': const Color(0xFF3B82F6)},
      {'name': 'موسيقى', 'icon': '🎵', 'color': const Color(0xFFEC4899)},
      {'name': 'ألعاب', 'icon': '🎮', 'color': const Color(0xFFF59E0B)},
      {'name': 'مواهب', 'icon': '⭐', 'color': const Color(0xFFEAB308)},
      {'name': 'تعارف', 'icon': '💕', 'color': const Color(0xFFEF4444)},
      {'name': 'قرآن', 'icon': '📖', 'color': const Color(0xFF14B8A6)},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('الأقسام'), backgroundColor: Colors.transparent, elevation: 0),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم اختيار قسم ${item['name']}')),
              );
              onCategorySelected?.call(item['name'] as String);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    (item['color'] as Color).withOpacity(0.9),
                    (item['color'] as Color).withOpacity(0.5),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['icon'] as String, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 8),
                  Text(item['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'عجلة الحظ', 'emoji': '🎡'},
      {'name': 'روليت', 'emoji': '🎰'},
      {'name': 'لودو', 'emoji': '🎲'},
      {'name': 'تحدي الغرفة', 'emoji': '🏆'},
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('الألعاب'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final g = games[i];
          return ListTile(
            tileColor: const Color(0xFF1A1A24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: Text(g['emoji']!, style: const TextStyle(fontSize: 28)),
            title: Text(g['name']!),
            trailing: const Icon(Icons.play_circle_fill, color: Color(0xFF8B5CF6)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${g['name']} سيتم تفعيلها بعد الأساس')),
              );
            },
          );
        },
      ),
    );
  }
}

class GiftsPage extends StatelessWidget {
  const GiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gifts = [
      {'e': '🌹', 'n': 'وردة', 'p': 10},
      {'e': '💖', 'n': 'قلب', 'p': 50},
      {'e': '👑', 'n': 'تاج', 'p': 500},
      {'e': '🚗', 'n': 'سيارة', 'p': 2000},
      {'e': '🏰', 'n': 'قصر', 'p': 8000},
      {'e': '🚀', 'n': 'صاروخ', 'p': 10000},
      {'e': '🐉', 'n': 'تنين', 'p': 20000},
      {'e': '🦄', 'n': 'يونيكورن', 'p': 25000},
      {'e': '🌟', 'n': 'نجم', 'p': 30000},
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('الهدايا'), backgroundColor: Colors.transparent, elevation: 0),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gifts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, i) {
          final g = gifts[i];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(g['e'] as String, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                Text(g['n'] as String),
                Text('${g['p']} 💰', style: const TextStyle(color: Colors.amber, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}
