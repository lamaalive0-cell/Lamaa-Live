import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  const ProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header VIP
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFF1493)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Color(0xFF8B5CF6),
                            child: Icon(Icons.person, size: 44, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                            child: const Icon(Icons.star, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: const Text('VIP 5', style: TextStyle(color: Color(0xFFFF1493), fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.badge, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('ID: ${userName.hashCode.abs()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Level Progress
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('المستوى 12', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          const Text('850 / 1000 XP', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.85, minHeight: 8,
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

          // إحصائيات
          Row(children: const [
            Expanded(child: _StatBox(icon: Icons.monetization_on, color: Colors.orange, title: 'كوينز', value: '0')),
            SizedBox(width: 10),
            Expanded(child: _StatBox(icon: Icons.diamond, color: Colors.cyan, title: 'ألماس', value: '0')),
          ]),
          const SizedBox(height: 10),
          Row(children: const [
            Expanded(child: _StatBox(icon: Icons.favorite, color: Colors.redAccent, title: 'معجبون', value: '0')),
            SizedBox(width: 10),
            Expanded(child: _StatBox(icon: Icons.people, color: Colors.blueAccent, title: 'متابعون', value: '0')),
          ]),

          const SizedBox(height: 20),

          // شارات
          const Text('🏅 الشارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
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

          const SizedBox(height: 20),

          // VIP Card
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
                      Text('احصل على مميزات حصرية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('اشترك', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // القوائم
          const _MenuTile(icon: Icons.edit, title: 'تعديل الملف الشخصي', color: Colors.blue),
          const _MenuTile(icon: Icons.wallet, title: 'المحفظة والشحن', color: Colors.green),
          const _MenuTile(icon: Icons.history, title: 'سجل الغرف', color: Colors.orange),
          const _MenuTile(icon: Icons.card_giftcard, title: 'هداياي', color: Colors.pink),
          const _MenuTile(icon: Icons.leaderboard, title: 'قائمة المتصدرين', color: Colors.amber),
          const _MenuTile(icon: Icons.security, title: 'الأمان والخصوصية', color: Colors.teal),
          const _MenuTile(icon: Icons.settings, title: 'الإعدادات', color: Colors.grey),
          const _MenuTile(icon: Icons.help_outline, title: 'المساعدة والدعم', color: Colors.purple),
          const _MenuTile(icon: Icons.info_outline, title: 'عن التطبيق', color: Colors.indigo),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, value;
  const _StatBox({required this.icon, required this.color, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String icon, name;
  const _Badge({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 10)),
      ]),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _MenuTile({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title - قريبًا')));
        },
      ),
    );
  }
}
