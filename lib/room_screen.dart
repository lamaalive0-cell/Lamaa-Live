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

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final chatController = TextEditingController();

  List<dynamic> seats = [];
  List<dynamic> dbGifts = [];
  final List<String> chat = [];
  bool loading = true;
  String? errorText;
  bool isMuted = false;

  late final String myUserId;

  // أنيميشن الهدايا الفخمة
  String? animEmoji;
  String? animName;
  String? animEffect;
  late final AnimationController _giftAnimController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    final authId = supabase.auth.currentUser?.id;
    myUserId = authId ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // إعداد أنيميشن الهدايا
    _giftAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _giftAnimController, curve: Curves.easeInOutBack));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_giftAnimController);

    _giftAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          animEmoji = null;
          animName = null;
          animEffect = null;
        });
      }
    });

    fetchSeats();
    fetchGifts();
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

  Future<void> fetchGifts() async {
    try {
      final data = await supabase
          .from('gifts')
          .select()
          .order('price', ascending: true);
      setState(() {
        dbGifts = data;
      });
    } catch (e) {
      debugPrint("خطأ في جلب الهدايا: $e");
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
      }).match({'room_id': widget.roomId, 'seat_index': index});
      return;
    }

    if (seat['user_id'] == myUserId) {
      await supabase.from('room_seats').update({
        'user_id': null,
        'user_name': null,
        'is_muted': false,
      }).match({'room_id': widget.roomId, 'seat_index': index});
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

  void triggerGiftAnimation(String emoji, String name, String effect) {
    setState(() {
      animEmoji = emoji;
      animName = name;
      animEffect = effect;
    });
    _giftAnimController.reset();
    _giftAnimController.forward();
  }

  void sendGift(Map<String, dynamic> gift) {
    final emoji = gift['emoji'] as String;
    final name = gift['name'] as String;
    final price = gift['price'] as int;
    final effect = (gift['effect'] ?? 'basic') as String;

    setState(() {
      chat.insert(0, '👑 ${widget.userName} أرسل $emoji $name بقيمة $price كوينز!');
    });

    triggerGiftAnimation(emoji, name, effect);
    _toast('تم إرسال $name 🎁');
  }

  void openGiftsStore() {
    String selectedCategory = 'الكل';
    String searchQuery = '';
    final categories = ['الكل', 'VIP تيكتوك', 'أسطورية', 'فخمة', 'ملكية', 'شعبية', 'عادية'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F0F1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = dbGifts.where((g) {
              final cat = g['category'] ?? 'عادية';
              final name = (g['name'] ?? '').toString();
              final matchesCat = selectedCategory == 'الكل' || cat == selectedCategory;
              final matchesSearch = searchQuery.isEmpty || name.contains(searchQuery);
              return matchesCat && matchesSearch;
            }).toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('👑 متجر الهدايا الفاخرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                        Text('${dbGifts.length} هدية', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // البحث
                    TextField(
                      onChanged: (v) => setModalState(() => searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن هدية (مثل: أسد، حوت، فيراري...)...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Colors.amber),
                        filled: true,
                        fillColor: const Color(0xFF1A1A2A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // التبويبات
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final c = categories[i];
                          final isSel = c == selectedCategory;
                          return ChoiceChip(
                            label: Text(c),
                            selected: isSel,
                            onSelected: (_) => setModalState(() => selectedCategory = c),
                            selectedColor: Colors.amber,
                            backgroundColor: const Color(0xFF1A1A2A),
                            labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // شبكة الهدايا الفاخرة
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('لا توجد هدايا تطابق البحث', style: TextStyle(color: Colors.white54)))
                          : GridView.builder(
                              itemCount: filtered.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              itemBuilder: (context, i) {
                                final gift = filtered[i];
                                final isVip = gift['category'] == 'VIP تيكتوك';
                                final isLegendary = gift['rarity'] == 'legendary';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    sendGift(gift);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: LinearGradient(
                                        colors: isVip
                                            ? const [Color(0xFF3B1054), Color(0xFF180A2A)]
                                            : isLegendary
                                                ? const [Color(0xFF4A3000), Color(0xFF1F1400)]
                                                : const [Color(0xFF1A1A2A), Color(0xFF12121D)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: isVip
                                            ? Colors.purpleAccent
                                            : isLegendary
                                                ? Colors.amber
                                                : const Color(0xFF2E2E48),
                                        width: isVip || isLegendary ? 1.5 : 1,
                                      ),
                                      boxShadow: isVip
                                          ? [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8)]
                                          : isLegendary
                                              ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 8)]
                                              : [],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(gift['emoji'] ?? '🎁', style: const TextStyle(fontSize: 34)),
                                        const SizedBox(height: 6),
                                        Text(
                                          gift['name'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${gift['price']} 💰',
                                            style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
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
              ),
            );
          },
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
    _giftAnimController.dispose();
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
              ? Center(child: Text(errorText!, style: const TextStyle(color: Colors.redAccent)))
              : Stack(
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          // الشريط العلوي
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
                                      Text(widget.roomTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text(widget.isVideo ? 'بث فيديو + صوت' : 'غرفة صوتية',
                                          style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                                  child: const Text('LIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),

                          // شاشة البث
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                colors: widget.isVideo
                                    ? const [Color(0xFF3B1A6D), Color(0xFF1A1030)]
                                    : const [Color(0xFF0F2A44), Color(0xFF101820)],
                              ),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(widget.isVideo ? Icons.videocam : Icons.graphic_eq, size: 44, color: Colors.white70),
                                  const SizedBox(height: 8),
                                  Text(onSeat ? 'أنت على المايك الآن 🎙️' : 'اضغط مقعدًا للصعود',
                                      style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

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
                                        child: Icon(occupied ? Icons.mic : Icons.add, color: Colors.white),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          seat['user_name'] ?? 'فارغ',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: chat.isEmpty
                                  ? const Center(child: Text('ابدأ الدردشة أو أرسل هدية 🎁', style: TextStyle(color: Colors.white54)))
                                  : ListView.builder(
                                      reverse: true,
                                      itemCount: chat.length,
                                      itemBuilder: (_, i) => Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                                        child: Text(chat[i], style: const TextStyle(fontSize: 13, color: Colors.amber)),
                                      ),
                                    ),
                            ),
                          ),

                          // شريط الأدوات السفلي
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
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                                    ),
                                    onSubmitted: (_) => sendChat(),
                                  ),
                                ),
                                IconButton(onPressed: sendChat, icon: const Icon(Icons.send, color: Color(0xFF8B5CF6))),
                                IconButton(onPressed: openGiftsStore, icon: const Icon(Icons.card_giftcard, color: Colors.amber, size: 28)),
                                IconButton(
                                  onPressed: () {
                                    if (!onSeat) {
                                      _toast('اصعد على مقعد أولًا');
                                      return;
                                    }
                                    setState(() => isMuted = !isMuted);
                                    _toast(isMuted ? 'تم كتم المايك' : 'تم فتح المايك');
                                  },
                                  icon: Icon(isMuted ? Icons.mic_off : Icons.mic, color: onSeat ? (isMuted ? Colors.redAccent : Colors.green) : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== أنيميشن الهدايا الفخمة والأسطورية =====
                    if (animEmoji != null)
                      IgnorePointer(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _giftAnimController,
                              builder: (context, _) {
                                return Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // هالة نورانية مشعة حول الهدية
                                        Container(
                                          padding: const EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: animEffect == 'lion_roar' || animEffect == 'gold_glow'
                                                    ? Colors.amber.withOpacity(0.8)
                                                    : animEffect == 'universe_vortex'
                                                        ? Colors.purpleAccent.withOpacity(0.8)
                                                        : Colors.blueAccent.withOpacity(0.8),
                                                blurRadius: 90,
                                                spreadRadius: 30,
                                              )
                                            ],
                                          ),
                                          child: Text(animEmoji!, style: const TextStyle(fontSize: 120)),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                                          ),
                                          child: Text(
                                            '🎉 ${widget.userName} أرسل $animName 🎉',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
