import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class RoomScreen extends StatefulWidget {
  final int roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final supabase = Supabase.instance.client;
  
  // ⚠️ ضع هنا الـ App ID الذي حصلت عليه من Agora
  final String agoraAppId = "888cd4788b404773bb0af444d26a5d4b";

  late RtcEngine _engine;
  bool isAgoraInit = false;
  List<dynamic> seats = [];
  int? mySeatIndex; // المقعد الذي أجلس عليه حالياً

  // معرف تجريبي للمستخدم
  final String myUserId = "user_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
  final String myUserName = "عضو لمعة";

  @override
  void initState() {
    super.initState();
    fetchSeats();
    listenToSeats();
    initAgora();
  }

  // 1. طلب صلاحيات المايك وتجهيز Agora
  Future<void> initAgora() async {
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("تم الدخول لقناة الصوت بنجاح: ${connection.channelId}");
        },
      ),
    );

    // الافتراضي: يدخل المستخدم كمستمع فقط (Audience)
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.enableAudio();
    
    // الدخول لغرفة الصوت برقم الغرفة
    await _engine.joinChannel(
      token: '',
      channelId: widget.roomId.toString(),
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() => isAgoraInit = true);
  }

  // 2. جلب المقاعد من Supabase
  void fetchSeats() async {
    final data = await supabase
        .from('room_seats')
        .select()
        .eq('room_id', widget.roomId)
        .order('seat_index', ascending: true);
    setState(() {
      seats = data;
      // معرفة إن كنت جالس على مقعد حالياً
      mySeatIndex = null;
      for (var seat in data) {
        if (seat['user_id'] == myUserId) {
          mySeatIndex = seat['seat_index'];
        }
      }
    });
  }

  // 3. التحديث اللحظي للمقاعد
  void listenToSeats() {
    supabase
        .channel('public:room_seats_${widget.roomId}')
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
            })
        .subscribe();
  }

  // 4. دالة الصعود أو النزول من المايك
  void toggleSeat(int index) async {
    final seat = seats[index];

    // إذا كان المقعد فارغاً وأنا لست على أي مقعد آخر -> اصعد
    if (seat['user_id'] == null && mySeatIndex == null) {
      await supabase.from('room_seats').update({
        'user_id': myUserId,
        'user_name': myUserName,
      }).match({'room_id': widget.roomId, 'seat_index': index});

      // فتح المايك وتحويل الحساب إلى متحدث (Broadcaster)
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    } 
    // إذا كنت أنا صاحب هذا المقعد وحاولت الضغط عليه مجدداً -> انزل
    else if (seat['user_id'] == myUserId) {
      await supabase.from('room_seats').update({
        'user_id': null,
        'user_name': null,
      }).match({'room_id': widget.roomId, 'seat_index': index});

      // كتم المايك وإعادة الحساب إلى مستمع فقط (Audience)
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("🎙️ غرفة لمعة رقم ${widget.roomId}"),
        backgroundColor: const Color(0xFF1F1F1F),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          // شبكة عرض المقاعد الثمانية
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
              itemCount: seats.length,
              itemBuilder: (context, index) {
                final seat = seats[index];
                final bool isOccupied = seat['user_id'] != null;
                final bool isMe = seat['user_id'] == myUserId;

                return GestureDetector(
                  onTap: () => toggleSeat(index),
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMe
                              ? Colors.green
                              : (isOccupied ? Colors.blue : Colors.grey[850]),
                          border: Border.all(
                            color: isOccupied ? Colors.cyanAccent : Colors.grey[700]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isOccupied ? Icons.mic : Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        seat['user_name'] ?? "مقعد فارغ",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isOccupied ? Colors.white : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // شريط معلومات سفلي
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1F1F1F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mySeatIndex != null ? Icons.mic : Icons.mic_off,
                  color: mySeatIndex != null ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  mySeatIndex != null ? "أنت الآن على المايك 🎙️" : "اضغط على أي مقعد للصعود",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}
