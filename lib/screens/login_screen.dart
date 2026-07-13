import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: '1234');
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<FarmProvider>().login(
      _userCtrl.text.trim(),
      _passCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) setState(() => _error = 'Credenciales incorrectas.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset('assets/images/smartfarm_logo.png', fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SmartFarm',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gestión inteligente de corrales IoT',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Iniciar sesión', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Ingresa tus credenciales de acceso',
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          const SizedBox(height: 20),

                          // Username
                          _FieldLabel('Usuario'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _userCtrl,
                            hint: 'admin',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 14),

                          // Password
                          _FieldLabel('Contraseña'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _passCtrl,
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 18,
                                color: AppColors.mutedForeground,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.destructiveBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.destructive.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.destructive, size: 16),
                                  const SizedBox(width: 8),
                                  Text(_error!, style: const TextStyle(color: AppColors.destructive, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _doLogin,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Ingresar al sistema'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Hint
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.infoBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.info.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.info_outline, size: 14, color: AppColors.info),
                          SizedBox(width: 8),
                          Text('Demo: cualquier usuario y contraseña',
                              style: TextStyle(fontSize: 11, color: AppColors.info)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('SmartFarm v1.0.0 · © 2025',
                        style: TextStyle(fontSize: 11, color: AppColors.mutedForeground.withOpacity(0.6))),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.foreground));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 14, color: AppColors.foreground),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
          prefixIcon: Icon(icon, size: 18, color: AppColors.mutedForeground),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
