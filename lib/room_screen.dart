import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';

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

  late final String myUserId;

  // 🌟 نظام محرك أنيميشن الهدايا (3D Overlay Engine)
  String? currentGiftAnimationUrl;
  late final AnimationController _overlayGiftController;

  // روابط افتراضية لملفات Lottie تحاكي تأثيرات تيك توك 3D (كمثال حي)
  final Map<String, String> premiumAnimations = {
    'الكون العظيم Universe 🌌': 'https://lottie.host/81b2382c-b570-4927-aa87-32115dc5fb1b/zH9tV8ZfV6.json', // تأثير المجرة والنجوم
    'الحوت الأزرق 🐋': 'https://lottie.host/791c6e14-e51b-4171-be84-b0a7dd650228/qU3wO2W8O7.json', // تأثير مائي مبهر
    'الأسد الذهبي 🦁': 'https://lottie.host/7e02e1de-baaf-4384-ad4b-bc54a72d73be/R4VlUoM9U2.json', // تأثير ناري
    'التنين الإمبراطوري 🐉': 'https://lottie.host/2df8f98d-697a-4c2f-b4c4-78338f0d8a57/PZQeH8i9X1.json', // تنين
  };

  @override
  void initState() {
    super.initState();
    final authId = supabase.auth.currentUser?.id;
    myUserId = authId ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // إعداد محرك تشغيل الهدايا بـ 60 FPS
    _overlayGiftController = AnimationController(vsync: this);
    _overlayGiftController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          currentGiftAnimationUrl = null; // إخفاء الهدية بعد الانتهاء
        });
        _overlayGiftController.reset();
      }
    });

    fetchSeats();
    fetchGifts();
  }

  Future<void> fetchSeats() async {
    final data = await supabase.from('room_seats').select().eq('room_id', widget.roomId).order('seat_index', ascending: true);
    setState(() {
      seats = data;
      loading = false;
    });
  }

  Future<void> fetchGifts() async {
    final data = await supabase.from('gifts').select().order('price', ascending: true);
    setState(() => dbGifts = data);
  }

  void triggerPremiumGift(String giftName) {
    // التحقق مما إذا كانت الهدية أسطورية ولها أنيميشن مخصص
    if (premiumAnimations.containsKey(giftName)) {
      setState(() {
        currentGiftAnimationUrl = premiumAnimations[giftName];
      });
    } else {
      // أنيميشن افتراضي للهدايا العادية (تأثير احتفال)
      setState(() {
        currentGiftAnimationUrl = 'https://lottie.host/3e7264a7-8f5c-4d32-bb94-0cfb4db0c1c4/t6XQ6sFfP9.json';
      });
    }
  }

  void sendGift(Map<String, dynamic> gift) {
    final emoji = gift['emoji'];
    final name = gift['name'];
    final price = gift['price'];

    setState(() {
      chat.insert(0, '🎁 ${widget.userName} أرسل $name ($price 💰)');
    });

    // تشغيل المحرك المرئي
    triggerPremiumGift(name);
  }

  void openGiftsStore() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F0F1A),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('💎 الهدايا الأسطورية (3D)', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dbGifts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, i) {
                    final g = dbGifts[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        sendGift(g);
                      },
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(g['emoji'], style: const TextStyle(fontSize: 34)),
                            Text(g['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.white)),
                            Text('${g['price']} 💰', style: const TextStyle(color: Colors.amber, fontSize: 12)),
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
      },
    );
  }

  @override
  void dispose() {
    _overlayGiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: Stack(
        children: [
          // 1️⃣ الطبقة الأولى: واجهة الغرفة العادية (شات، مقاعد، هيدر)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Center(child: Text("منطقة البث والمقاعد هنا", style: TextStyle(color: Colors.white54))),
                const Spacer(),
                ElevatedButton(
                  onPressed: openGiftsStore,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("افتح متجر الهدايا 🎁", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),

          // 2️⃣ الطبقة الثانية (OVERLAY 3D ENGINE): تعادل (Z-Index + Pointer-events: none)
          if (currentGiftAnimationUrl != null)
            IgnorePointer( // 👈 تمنع الأنيميشن من حجب اللمس عن الأزرار خلفه!
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.3), // تعتيم خفيف للخلفية لإبراز الـ 3D
                child: Center(
                  child: Lottie.network(
                    currentGiftAnimationUrl!,
                    controller: _overlayGiftController,
                    fit: BoxFit.cover, // يغطي الشاشة بالكامل
                    onLoaded: (composition) {
                      // تشغيل الأنيميشن تلقائياً بكامل مدته
                      _overlayGiftController
                        ..duration = composition.duration
                        ..forward();
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
