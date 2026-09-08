import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool hidePassword = true;

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _show('أكمل جميع الحقول');
      return;
    }
    if (password.length < 6) {
      _show('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': name,
          'display_name': name,
        },
      );

      if (!mounted) return;
      _show('تم إنشاء الحساب بنجاح ✅');
      Navigator.pop(context); // ارجع لشاشة الدخول
    } on AuthException catch (e) {
      _show(e.message);
    } catch (e) {
      _show('فشل إنشاء الحساب: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'انضم إلى Lamaa Live 🎙️',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'أنشئ حسابك وابدأ البث الآن',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 28),

              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _input('اسم العرض', Icons.person_outline),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _input('الإيميل', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _input(
                  'كلمة المرور',
                  Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => hidePassword = !hidePassword),
                    icon: Icon(
                      hidePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'إنشاء الحساب',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF1A1A24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
