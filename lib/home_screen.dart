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
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            RoomsPage(userName: widget.userName),
            const SimplePage(title: 'الأقسام', text: 'الأقسام قريبًا'),
            const SimplePage(title: 'الألعاب', text: 'الألعاب قريبًا'),
            const SimplePage(title: 'الهدايا', text: 'الهدايا قريبًا'),
            SimplePage(title: 'حسابي', text: 'مرحبًا ${widget.userName}'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) => setState(() => tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
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

class SimplePage extends StatelessWidget {
  final String title;
  final String text;
  const SimplePage({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('الغرف المباشرة'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            onPressed: loadRooms,
            icon: const Icon(Icons.refresh),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: loadRooms,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : rooms.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد غرف\nاضغط إنشاء غرفة',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return Card(
                          color: const Color(0xFF1E1E1E),
                          child: ListTile(
                            leading: const Icon(Icons.mic, color: Colors.greenAccent),
                            title: Text(
                              '${room['title'] ?? 'غرفة'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'ID: ${room['id']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
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
                              loadRooms();
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
