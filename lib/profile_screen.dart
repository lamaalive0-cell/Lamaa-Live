import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  const ProfileScreen({super.key, required this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? profile;
  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      loading = true;
      errorText = null;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
          errorText = 'يجب تسجيل الدخول';
        });
        return;
      }

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        final created = await supabase.from('profiles').insert({
          'id': user.id,
          'username': widget.userName,
          'display_name': widget.userName,
          'coins': 1000,
          'diamonds': 0,
          'level': 1,
          'xp': 0,
          'vip_level': 0,
          'followers_count': 0,
          'following_count': 0,
        }).select().single();

        setState(() {
          profile = created;
          loading = false;
        });
      } else {
        setState(() {
          profile = data;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorText = e.toString();
      });
    }
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الخروج: $e')),
      );
    }
  }

  Future<void> editName() async {
    final controller = TextEditingController(
      text: profile?['display_name']?.toString() ?? widget.userName,
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: const Text('تعديل الاسم'),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'اسمك الجديد',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('profiles').update({
        'display_name': newName,
        'username': newName,
      }).eq('id', user.id);

      await loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الاسم ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحديث: $e')),
      );
    }
  }

  void comingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title قريبًا ضمن الأساس التالي')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorText != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorText!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: loadProfile, child: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      );
    }

    final name = profile?['display_name']?.toString() ?? widget.userName;
    final level = profile?['level'] ?? 1;
    final xp = profile?['xp'] ?? 0;
    final coins = profile?['coins'] ?? 0;
    final diamonds = profile?['diamonds'] ?? 0;
    final vip = profile?['vip_level'] ?? 0;
    final followers = profile?['followers_count'] ?? 0;
    final following = profile?['following_count'] ?? 0;
    final userId = supabase.auth.currentUser?.id ?? '';
    final shortId = userId.length > 8 ? userId.substring(0, 8) : userId;
    final xpProgress = ((xp % 1000) / 1000).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Header =====
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.white, Colors.amber]),
                      ),
                      child: const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFF2A1A4A),
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'VIP $vip',
                                  style: const TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('ID: $shortId', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: editName,
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('المستوى $level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('$xp XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ===== Stats =====
          Row(
            children: [
              Expanded(child: _statCard(Icons.monetization_on, Colors.orange, 'الكوينز', '$coins')),
              const SizedBox(width: 10),
              Expanded(child: _statCard(Icons.diamond, Colors.cyan, 'الألماس', '$diamonds')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statCard(Icons.people, Colors.blueAccent, 'المتابعون', '$followers')),
              const SizedBox(width: 10),
              Expanded(child: _statCard(Icons.person_add_alt_1, Colors.purpleAccent, 'أتابع', '$following')),
            ],
          ),

          const SizedBox(height: 18),

          // ===== Badges =====
          const Text('🏅 الشارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 86,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _Badge(icon: '🥇', name: 'ذهبية'),
                _Badge(icon: '💎', name: 'ألماس'),
                _Badge(icon: '👑', name: 'ملك'),
                _Badge(icon: '🔥', name: 'نار'),
                _Badge(icon: '⭐', name: 'نجم'),
                _Badge(icon: '🚀', name: 'صاروخ'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ===== VIP Card =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('العضوية VIP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('مميزات حصرية وإطار ذهبي', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => comingSoon('نظام VIP'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('ترقية', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Text('الإعدادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          _menuTile(Icons.edit, 'تعديل الاسم', editName),
          _menuTile(Icons.account_balance_wallet, 'المحفظة والشحن', () => comingSoon('المحفظة')),
          _menuTile(Icons.card_giftcard, 'هداياي', () => comingSoon('هداياي')),
          _menuTile(Icons.history, 'سجل الغرف', () => comingSoon('سجل الغرف')),
          _menuTile(Icons.leaderboard, 'قائمة المتصدرين', () => comingSoon('المتصدرين')),
          _menuTile(Icons.security, 'الأمان والخصوصية', () => comingSoon('الأمان')),
          _menuTile(Icons.settings, 'الإعدادات', () => comingSoon('الإعدادات')),
          _menuTile(Icons.help_outline, 'المساعدة والدعم', () => comingSoon('المساعدة')),
          _menuTile(Icons.info_outline, 'عن التطبيق', () => comingSoon('عن التطبيق')),
          _menuTile(Icons.refresh, 'تحديث البيانات', loadProfile),
          _menuTile(Icons.logout, 'تسجيل الخروج', logout, danger: true),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap, {bool danger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: danger ? Colors.red.withOpacity(0.08) : const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: danger ? Colors.redAccent : Colors.white70),
        title: Text(title, style: TextStyle(color: danger ? Colors.redAccent : Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String icon;
  final String name;
  const _Badge({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
