import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomScreen extends StatefulWidget {
  final int roomId;
  final String userName;
  final bool isVideo;
  final String roomTitle;

  const RoomScreen({
    super.key,
    required this.roomId,
    required this.userName,
    this.isVideo = true,
    this.roomTitle = 'غرفة لايف',
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> seats = [];
  bool loading = true;
  String? errorText;
  final List<String> chat = [];

  final String myUserId =
      'user_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

  final chatController = TextEditingController();

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
        .channel('room_${widget.roomId}_seats')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'room_seats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: widget.roomId,
          ),
          callback: (_) => fetchSeats(),
        )
        .subscribe();
  }

  Future<void> toggleSeat(int index) async {
    if (seats.isEmpty) return;
    final seat = seats[index];

    if (seat['user_id'] == null) {
      final already = seats.any((s) => s['user_id'] == myUserId);
      if (already) return;
      await supabase.from('room_seats').update({
        'user_id': myUserId,
        'user_name': widget.userName,
      }).match({'room_id': widget.roomId, 'seat_index': index});
      return;
    }

    if (seat['user_id'] == myUserId) {
      await supabase.from('room_seats').update({
        'user_id': null,
        'user_name': null,
      }).match({'room_id': widget.roomId, 'seat_index': index});
    }
  }

  void sendChat() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      chat.insert(0, '${widget.userName}: $text');
      chatController.clear();
    });
  }

  void sendGift(String gift) {
    setState(() {
      chat.insert(0, '🎁 ${widget.userName} أرسل $gift');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال $gift')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorText != null
              ? Center(child: Text(errorText!, style: const TextStyle(color: Colors.redAccent)))
              : Stack(
                  children: [
                    // خلفية فيديو/بث
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isVideo
                              ? const [Color(0xFF2A1248), Color(0xFF0B0B10)]
                              : const [Color(0xFF0F2438), Color(0xFF0B0B10)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Column(
                        children: [
                          // Top bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close, color: Colors.white),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.roomTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(widget.isVideo ? 'فيديو + صوت' : 'صوت فقط',
                                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('LIVE', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),

                          // منطقة البث الرئيسية
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(widget.isVideo ? Icons.videocam : Icons.mic,
                                      size: 42, color: Colors.white70),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.isVideo
                                        ? 'منطقة الفيديو (Agora قريبًا)'
                                        : 'غرفة صوتية جاهزة للمقاعد',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // المقاعد
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: seats.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                                            ? const Color(0xFF22C55E)
                                            : occupied
                                                ? const Color(0xFF3B82F6)
                                                : const Color(0xFF2A2A35),
                                        child: Icon(
                                          occupied ? Icons.mic : Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          seat['user_name'] ?? 'فارغ',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // الشات
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: chat.isEmpty
                                  ? const Center(
                                      child: Text('ابدأ الدردشة أو أرسل هدية 🎁',
                                          style: TextStyle(color: Colors.white54)),
                                    )
                                  : ListView.builder(
                                      reverse: true,
                                      itemCount: chat.length,
                                      itemBuilder: (_, i) => Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(chat[i], style: const TextStyle(fontSize: 13)),
                                      ),
                                    ),
                            ),
                          ),

                          // شريط الأدوات
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: chatController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'اكتب رسالة...',
                                      hintStyle: const TextStyle(color: Colors.white38),
                                      filled: true,
                                      fillColor: const Color(0xFF1A1A24),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: sendChat,
                                  icon: const Icon(Icons.send, color: Color(0xFF8B5CF6)),
                                ),
                                IconButton(
                                  onPressed: () => sendGift('🌹 وردة'),
                                  icon: const Icon(Icons.card_giftcard, color: Colors.amber),
                                ),
                                IconButton(
                                  onPressed: () => sendGift('👑 تاج'),
                                  icon: const Icon(Icons.workspace_premium, color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
