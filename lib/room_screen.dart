import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomScreen extends StatefulWidget {
  final int roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> seats = [];
  bool loading = true;
  String? errorText;

  final String myUserId =
      'user_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  final String myUserName = 'عضو لمعة';

  @override
  void initState() {
    super.initState();
    fetchSeats();
    listenToSeats();
  }

  Future<void> fetchSeats() async {
    try {
      final data = await supabase
          .from('room_seats')
          .select()
          .eq('room_id', widget.roomId)
          .order('seat_index', ascending: true);

      setState(() {
        seats = data;
        loading = false;
        errorText = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorText = e.toString();
      });
    }
  }

  void listenToSeats() {
    supabase
        .channel('room_seats_room_${widget.roomId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'room_seats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: widget.roomId,
          ),
          callback: (payload) {
            fetchSeats();
          },
        )
        .subscribe();
  }

  Future<void> toggleSeat(int index) async {
    if (seats.isEmpty) return;
    final seat = seats[index];

    // صعود على مقعد فارغ
    if (seat['user_id'] == null) {
      // تأكد أني مو جالس على مقعد ثاني
      final alreadySeated = seats.any((s) => s['user_id'] == myUserId);
      if (alreadySeated) return;

      await supabase.from('room_seats').update({
        'user_id': myUserId,
        'user_name': myUserName,
      }).match({
        'room_id': widget.roomId,
        'seat_index': index,
      });
      return;
    }

    // نزول من مقعدي
    if (seat['user_id'] == myUserId) {
      await supabase.from('room_seats').update({
        'user_id': null,
        'user_name': null,
      }).match({
        'room_id': widget.roomId,
        'seat_index': index,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('غرفة لمعة رقم ${widget.roomId}'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorText != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'خطأ:\n$errorText',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: seats.length,
                        itemBuilder: (context, index) {
                          final seat = seats[index];
                          final occupied = seat['user_id'] != null;
                          final isMe = seat['user_id'] == myUserId;

                          return GestureDetector(
                            onTap: () => toggleSeat(index),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: isMe
                                      ? Colors.green
                                      : occupied
                                          ? Colors.blue
                                          : Colors.grey[800],
                                  child: Icon(
                                    occupied ? Icons.mic : Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  seat['user_name'] ?? 'فارغ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('اضغط مقعد فارغ للصعود، واضغط مقعدك للنزول'),
                    ),
                  ],
                ),
    );
  }
}
