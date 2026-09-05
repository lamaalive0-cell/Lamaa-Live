import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomScreen extends StatefulWidget {
  final int roomId; // رقم الغرفة
  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> seats = [];

  @override
  void initState() {
    super.initState();
    fetchSeats();
    listenToSeats();
  }

  // 1. جلب المقاعد من قاعدة البيانات
  void fetchSeats() async {
    final data = await supabase
        .from('room_seats')
        .select()
        .eq('room_id', widget.roomId)
        .order('seat_index', ascending: true);
    setState(() => seats = data);
  }

  // 2. الاستماع للتغييرات اللحظية (Realtime)
  void listenToSeats() {
    supabase
        .channel('public:room_seats')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'room_seats',
            callback: (payload) {
              fetchSeats(); // تحديث الشاشة فوراً عند حدوث أي تغيير
            })
        .subscribe();
  }

  // 3. دالة الصعود على المايك
  void takeSeat(int index) async {
    await supabase.from('room_seats').update({
      'user_id': 'user_test', // مؤقتاً
      'user_name': 'لاعب جديد 🎙️',
    }).match({'room_id': widget.roomId, 'seat_index': index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الغرفة رقم ${widget.roomId}")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // عرض المقاعد الثمانية
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: seats.length,
              itemBuilder: (context, index) {
                final seat = seats[index];
                return GestureDetector(
                  onTap: () => takeSeat(index),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: seat['user_id'] == null ? Colors.grey[800] : Colors.blue,
                        child: Icon(seat['user_id'] == null ? Icons.add : Icons.person, color: Colors.white),
                      ),
                      Text(seat['user_name'] ?? "فارغ", style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          const Text("اضغط على أي مقعد للصعود على المايك"),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
