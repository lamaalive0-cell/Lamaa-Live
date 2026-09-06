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
  final supabase = Supabase.instance.client;
  List<dynamic> rooms = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final data = await supabase
        .from('rooms')
        .select()
        .order('id', ascending: false);

    setState(() {
      rooms = data;
      loading = false;
    });
  }

  Future<void> createRoom() async {
    final inserted = await supabase.from('rooms').insert({
      'title': 'غرفة ${widget.userName}',
      'host_id': '00000000-0000-0000-0000-000000000001',
    }).select().single();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomScreen(
          roomId: inserted['id'] as int,
          userName: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('مرحبًا ${widget.userName}'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createRoom,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('إنشاء غرفة'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? const Center(child: Text('لا توجد غرف بعد'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        leading: const Icon(Icons.mic, color: Colors.greenAccent),
                        title: Text(room['title'] ?? 'غرفة'),
                        subtitle: Text('ID: ${room['id']}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoomScreen(
                                roomId: room['id'] as int,
                                userName: widget.userName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
