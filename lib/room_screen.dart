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
  final chatController = TextEditingController();

  List<dynamic> seats = [];
  final List<String> chat = [];
  bool loading = true;
  String? errorText;
  bool isMuted = false;

  late final String myUserId;

  final gifts = const [
    {'e': '🌹', 'n': 'وردة', 'p': 10},
    {'e': '💖', 'n': 'قلب', 'p': 50},
    {'e': '👑', 'n': 'تاج', 'p': 500},
    {'e': '🚗', 'n': 'سيارة', 'p': 2000},
    {'e': '🚀', 'n': 'صاروخ', 'p': 10000},
  ];

  @override
  void initState() {
    super.initState();
    final authId = supabase.auth.currentUser?.id;
    myUserId = authId ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
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
        .channel('room_seats_${widget.roomId}')
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

    // صعود
    if (seat['user_id'] == null) {
      final already = seats.any((s) => s['user_id'] == myUserId);
      if (already) {
        _toast('أنت بالفعل على مقعد');
        return;
      }

      await supabase.from('room_seats').update({
        'user_id': myUserId,
        'user_name': widget.userName,
        'is_muted': false,
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
        'is_muted': false,
      }).match({
        'room_id': widget.roomId,
        'seat_index': index,
      });
    } else {
      _toast('المقعد مشغول');
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

  void sendGift(Map<String, Object> gift) {
    setState(() {
      chat.insert(0, '🎁 ${widget.userName} أرسل ${gift['e']} ${gift['n']}');
    });
    _toast('تم إرسال ${gift['n']}');
  }

  void openGifts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('إرسال هدية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                itemCount: gifts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, i) {
                  final g = gifts[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      sendGift(g);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${g['e']}', style: const TextStyle(fontSize: 22)),
                          Text('${g['p']}', style: const TextStyle(fontSize: 10, color: Colors.amber)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSeat = seats.any((s) => s['user_id'] == myUserId);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorText != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(errorText!, style: const TextStyle(color: Colors.redAccent)),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // ===== Top Bar =====
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
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
                                  Text(
                                    widget.roomTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    widget.isVideo ? 'بث فيديو + صوت' : 'غرفة صوتية',
                                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle, size: 8, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('LIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===== Stage / Video area =====
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        height: 190,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: widget.isVideo
                                ? const [Color(0xFF3B1A6D), Color(0xFF1A1030)]
                                : const [Color(0xFF0F2A44), Color(0xFF101820)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.isVideo ? Icons.videocam : Icons.graphic_eq,
                                    size: 46,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.isVideo
                                        ? 'منطقة الفيديو جاهزة للربط'
                                        : 'منطقة الصوت جاهزة للربط',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    onSeat ? 'أنت على المايك الآن' : 'اضغط مقعدًا للصعود',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('ID ${widget.roomId}', style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ===== Seats =====
                      SizedBox(
                        height: 118,
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
                                  Container(
                                    width: 66,
                                    height: 66,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isMe
                                          ? const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)])
                                          : occupied
                                              ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)])
                                              : null,
                                      color: occupied || isMe ? null : const Color(0xFF232333),
                                      border: Border.all(
                                        color: isMe
                                            ? const Color(0xFF4ADE80)
                                            : occupied
                                                ? const Color(0xFF60A5FA)
                                                : const Color(0xFF3A3A4A),
                                        width: 2,
                                      ),
                                      boxShadow: isMe
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF22C55E).withOpacity(0.35),
                                                blurRadius: 12,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Icon(
                                      occupied ? Icons.mic : Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 72,
                                    child: Text(
                                      seat['user_name'] ?? 'فارغ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: occupied ? Colors.white : Colors.white54,
                                      ),
                                    ),
                                  ),
                                  Text('مقعد ${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // ===== Chat =====
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: chat.isEmpty
                              ? const Center(
                                  child: Text(
                                    'ابدأ الدردشة أو أرسل هدية 🎁',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: chat.length,
                                  itemBuilder: (_, i) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(chat[i], style: const TextStyle(fontSize: 13)),
                                    );
                                  },
                                ),
                        ),
                      ),

                      // ===== Bottom tools =====
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onSubmitted: (_) => sendChat(),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _roundBtn(Icons.send, const Color(0xFF8B5CF6), sendChat),
                            _roundBtn(Icons.card_giftcard, Colors.amber, openGifts),
                            _roundBtn(
                              isMuted ? Icons.mic_off : Icons.mic,
                              onSeat ? (isMuted ? Colors.redAccent : Colors.green) : Colors.grey,
                              () {
                                if (!onSeat) {
                                  _toast('اصعد على مقعد أولًا');
                                  return;
                                }
                                setState(() => isMuted = !isMuted);
                                _toast(isMuted ? 'تم كتم المايك' : 'تم فتح المايك');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _roundBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color),
      ),
    );
  }
}
