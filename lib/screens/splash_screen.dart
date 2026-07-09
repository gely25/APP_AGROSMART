import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Splash screen — matches the React SplashScreen with pop animation and bounce dots.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _popCtrl;
  late Animation<double> _popScale;
  late Animation<double> _popOpacity;

  late List<AnimationController> _dotCtrls;

  @override
  void initState() {
    super.initState();

    // Logo pop animation (600ms — matches React animate-[pop_600ms])
    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _popScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut),
    );
    _popOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut),
    );

    // Bounce dots — 3 controllers with staggered start
    _dotCtrls = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    ));

    // Start logo pop
    _popCtrl.forward();

    // Start dots after logo
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) _dotCtrls[i].repeat(reverse: true);
        });
      }
    });

    // Navigate after 2200ms (matches React setTimeout)
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _popCtrl.dispose();
    for (final c in _dotCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with blur + opacity
            Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.40),
              colorBlendMode: BlendMode.modulate,
            ),
            // Primary overlay
            Container(color: AppColors.primary.withOpacity(0.70)),

            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with pop animation
                AnimatedBuilder(
                  animation: _popCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _popOpacity.value,
                    child: Transform.scale(
                      scale: _popScale.value,
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 112, height: 112,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 32, offset: Offset(0, 8)),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.20), width: 4),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/smartfarm_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Title
                Text(
                  'SMARTFARM',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Corral Pecuario Inteligente',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),

                const SizedBox(height: 48),

                // Bounce dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedBuilder(
                      animation: _dotCtrls[i],
                      builder: (_, __) {
                        final v = _dotCtrls[i].value;
                        return Transform.translate(
                          offset: Offset(0, -8 * v),
                          child: Container(
                            width: 10, height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.90),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
