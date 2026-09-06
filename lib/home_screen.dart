import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'room_screen.dart';

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
      backgroundColor: const Color(0xFF0E0E14),
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            RoomsPage(userName: widget.userName),
            CategoriesPage(userName: widget.userName),
            GamesPage(userName: widget.userName),
            GiftsPage(userName: widget.userName),
            ProfilePage(userName: widget.userName),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A2A35))),
        ),
        child: BottomNavigationBar(
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
  List<dynamic> rooms = [];
  bool loading = true;
  String? errorText;
  String selectedCategory = 'الكل';

  final categories = const ['الكل', 'دردشة', 'موسيقى', 'ألعاب', 'مواهب'];

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('إنشاء غرفة لايف',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'اسم الغرفة',
                      filled: true,
                      fillColor: const Color(0xFF12121A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    dropdownColor: const Color(0xFF1A1A24),
                    decoration: InputDecoration(
                      labelText: 'القسم',
                      filled: true,
                      fillColor: const Color(0xFF12121A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'دردشة', child: Text('دردشة')),
                      DropdownMenuItem(value: 'موسيقى', child: Text('موسيقى')),
                      DropdownMenuItem(value: 'ألعاب', child: Text('ألعاب')),
                      DropdownMenuItem(value: 'مواهب', child: Text('مواهب')),
                    ],
                    onChanged: (v) => setModalState(() => category = v ?? 'دردشة'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: isVideo,
                    activeColor: const Color(0xFF8B5CF6),
                    title: const Text('غرفة فيديو + صوت'),
                    subtitle: const Text('إذا أغلقتها تكون صوت فقط'),
                    onChanged: (v) => setModalState(() => isVideo = v),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'title': titleController.text.trim(),
                          'category': category,
                          'is_video': isVideo,
                        });
                      },
                      child: const Text('بدء البث', style: TextStyle(color: Colors.white)),
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
    if ((result['title'] as String).isEmpty) return;

    try {
      final inserted = await supabase
          .from('rooms')
          .insert({
            'title': result['title'],
            'host_id': '00000000-0000-0000-0000-000000000001',
            'category': result['category'],
            'is_video': result['is_video'],
          })
          .select()
          .single();

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomScreen(
            roomId: inserted['id'] as int,
            userName: widget.userName,
            isVideo: result['is_video'] == true,
            roomTitle: result['title'] as String,
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

  @override
  Widget build(BuildContext context) {
    final list = filteredRooms;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createRoom,
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.videocam, color: Colors.white),
        label: const Text('بث جديد', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('الغرف المباشرة',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: loadRooms, icon: const Icon(Icons.refresh)),
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
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey[300]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : errorText != null
                    ? Center(child: Text(errorText!, style: const TextStyle(color: Colors.redAccent)))
                    : list.isEmpty
                        ? const Center(child: Text('لا توجد غرف في هذا القسم', style: TextStyle(color: Colors.grey)))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final room = list[index];
                              final isVideo = room['is_video'] == true;
                              return InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RoomScreen(
                                        roomId: room['id'] as int,
                                        userName: widget.userName,
                                        isVideo: isVideo,
                                        roomTitle: room['title'] ?? 'غرفة',
                                      ),
                                    ),
                                  );
                                  loadRooms();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: LinearGradient(
                                      colors: isVideo
                                          ? const [Color(0xFF2B174F), Color(0xFF1A1A24)]
                                          : const [Color(0xFF14233A), Color(0xFF1A1A24)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(color: const Color(0xFF2F2F3C)),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const Spacer(),
                                          Icon(isVideo ? Icons.videocam : Icons.mic, color: Colors.white70, size: 18),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        room['title'] ?? 'غرفة',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        room['category'] ?? 'دردشة',
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('ID ${room['id']}', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
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
  final String userName;
  const CategoriesPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'دردشة', 'icon': Icons.chat_bubble, 'color': Colors.blue},
      {'name': 'موسيقى', 'icon': Icons.music_note, 'color': Colors.pink},
      {'name': 'ألعاب', 'icon': Icons.sports_esports, 'color': Colors.orange},
      {'name': 'مواهب', 'icon': Icons.star, 'color': Colors.amber},
      {'name': 'تعارف', 'icon': Icons.favorite, 'color': Colors.redAccent},
      {'name': 'تعليماو', 'icon': Icons.school, 'color': Colors.teal},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('الأقسام'), backgroundColor: Colors.transparent),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF2F2F3C)),
            ),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فلترة قسم ${item['name']} من تبويب الغرف')),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData, size: 36, color: item['color'] as Color),
                  const SizedBox(height: 10),
                  Text(item['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
  final String userName;
  const GamesPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'عجلة الحظ', 'emoji': '🎡', 'desc': 'اربح كوينز يوميًا'},
      {'name': 'روليت', 'emoji': '🎰', 'desc': 'لعبة الحظ السريعة'},
      {'name': 'لودو', 'emoji': '🎲', 'desc': 'العب مع الأصدقاء'},
      {'name': 'تحدي الغرفة', 'emoji': '🏆', 'desc': 'تحديات مباشرة'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('الألعاب'), backgroundColor: Colors.transparent),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final g = games[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(g['emoji']!, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(g['desc']!, style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('سيتم ربط ${g['name']} قريبًا داخل الغرف')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                  child: const Text('لعب', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GiftsPage extends StatelessWidget {
  final String userName;
  const GiftsPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final gifts = [
      {'emoji': '🌹', 'name': 'وردة', 'price': 10},
      {'emoji': '💖', 'name': 'قلب', 'price': 50},
      {'emoji': '👑', 'name': 'تاج', 'price': 300},
      {'emoji': '🚗', 'name': 'سيارة', 'price': 1000},
      {'emoji': '🏰', 'name': 'قصر', 'price': 5000},
      {'emoji': '🚀', 'name': 'صاروخ', 'price': 10000},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('متجر الهدايا'), backgroundColor: Colors.transparent),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gifts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
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
                Text(g['emoji'] as String, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                Text(g['name'] as String),
                Text('${g['price']} 💎', style: const TextStyle(color: Colors.amber)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String userName;
  const ProfilePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('حسابي'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2B174F), Color(0xFF1A1A24)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('ID: guest_user', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _StatCard(title: 'الكوينز', value: '0', icon: Icons.monetization_on, color: Colors.orange)),
              SizedBox(width: 10),
              Expanded(child: _StatCard(title: 'الألماس', value: '0', icon: Icons.diamond, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 12),
          const _MenuTile(icon: Icons.edit, title: 'تعديل الملف'),
          const _MenuTile(icon: Icons.history, title: 'سجل الغرف'),
          const _MenuTile(icon: Icons.settings, title: 'الإعدادات'),
          const _MenuTile(icon: Icons.help_outline, title: 'المساعدة'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const _MenuTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A24),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
