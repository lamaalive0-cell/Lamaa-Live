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
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      RoomsTab(userName: widget.userName),
      const CategoriesTab(),
      const GamesTab(),
      const GiftsTab(),
      ProfileTab(userName: widget.userName),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(child: pages[currentTab]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (i) => setState(() => currentTab = i),
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'الغرف'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'الأقسام'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'الألعاب'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'الهدايا'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ========== 1) تبويب الغرف ==========
class RoomsTab extends StatefulWidget {
  final String userName;
  const RoomsTab({super.key, required this.userName});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  final supabase = Supabase.instance.client;
  List<dynamic> rooms = [];
  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    setState(() {
      loading = true;
      errorText = null;
    });
    try {
      final data = await supabase
          .from('rooms')
          .select()
          .order('id', ascending: false);

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

  Future<void> createRoom() async {
    try {
      final inserted = await supabase
          .from('rooms')
          .insert({
            'title': 'غرفة ${widget.userName}',
            'host_id': '00000000-0000-0000-0000-000000000001',
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
          ),
        ),
      );
      fetchRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الإنشاء: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('الغرف المباشرة 🎙️'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRooms,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createRoom,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('إنشاء غرفة'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorText != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 60),
                        const SizedBox(height: 10),
                        Text(errorText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchRooms,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : rooms.isEmpty
                  ? const Center(
                      child: Text('لا توجد غرف بعد\nاضغط + لإنشاء غرفة',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return Card(
                          color: const Color(0xFF1E1E1E),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Icon(Icons.mic, color: Colors.white),
                            ),
                            title: Text(room['title'] ?? 'غرفة',
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text('غرفة رقم ${room['id']}',
                                style: const TextStyle(color: Colors.grey)),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.grey),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RoomScreen(
                                    roomId: room['id'] as int,
                                    userName: widget.userName,
                                  ),
                                ),
                              );
                              fetchRooms();
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

// ========== 2) تبويب الأقسام ==========
class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'دردشة', 'icon': Icons.chat, 'color': 
