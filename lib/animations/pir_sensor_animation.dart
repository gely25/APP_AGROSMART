import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PirSensorAnimation extends StatefulWidget {
  final bool motionDetected;

  const PirSensorAnimation({super.key, required this.motionDetected});

  @override
  State<PirSensorAnimation> createState() => _PirSensorAnimationState();
}

class _PirSensorAnimationState extends State<PirSensorAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.motionDetected) {
      _waveCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(PirSensorAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motionDetected != widget.motionDetected) {
      if (widget.motionDetected) {
        _waveCtrl.repeat();
      } else {
        _waveCtrl.stop();
        _waveCtrl.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 192,
        child: Stack(
          children: [
            // Sky gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.sky1, AppColors.sky2],
                ),
              ),
            ),
            // Grass
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 72,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.grass1, AppColors.grass2],
                  ),
                ),
              ),
            ),
            // Grass divider
            Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              height: 8,
              child: Container(color: AppColors.grass3),
            ),

            // Left fence
            Positioned(
              bottom: 40,
              left: -10,
              child: _FenceMock(),
            ),

            // Main support post where PIR sensor is mounted
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 24,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A939B), Color(0xFFB5BEC6), Color(0xFF6C757D)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated detection waves (radar rings)
            if (widget.motionDetected)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _RadarWavesPainter(
                        progress: _waveCtrl.value,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),

            // PIR Sensor Case & Lens
            Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    // Bracket
                    Container(
                      width: 12,
                      height: 10,
                      color: const Color(0xFF495057),
                    ),
                    // Sensor Body
                    Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCED4DA), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Lens (Fresnel Dome)
                          Positioned(
                            top: 4,
                            child: AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (context, child) {
                                final color = widget.motionDetected
                                    ? AppColors.primary
                                    : AppColors.info;
                                final glow = widget.motionDetected
                                    ? 0.4 + _pulseCtrl.value * 0.6
                                    : 0.1 + _pulseCtrl.value * 0.2;
                                return Container(
                                  width: 28,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(widget.motionDetected ? 0.8 : 0.4),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(glow),
                                        blurRadius: widget.motionDetected ? 12 : 4,
                                        spreadRadius: widget.motionDetected ? 4 : 1,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Small Status LED
                          Positioned(
                            bottom: 4,
                            right: 6,
                            child: AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (context, _) {
                                final ledColor = widget.motionDetected
                                    ? Colors.red
                                    : Colors.green;
                                final isLit = widget.motionDetected
                                    ? true
                                    : _pulseCtrl.value > 0.5;
                                return Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isLit ? ledColor : ledColor.withOpacity(0.2),
                                    boxShadow: [
                                      if (isLit)
                                        BoxShadow(
                                          color: ledColor,
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FenceMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 60,
      child: Stack(
        children: [
          // Rail
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            height: 6,
            child: Container(
              color: AppColors.wood,
            ),
          ),
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            height: 6,
            child: Container(
              color: AppColors.wood,
            ),
          ),
          // Vertical posts
          ...List.generate(6, (i) {
            return Positioned(
              left: 40.0 + i * 70.0,
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(
                color: AppColors.woodDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RadarWavesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarWavesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 110);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw 3 expanding rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i / 3.0) % 1.0;
      final radius = 25.0 + ringProgress * 90.0;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0);

      paint.color = color.withOpacity(opacity * 0.6);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RadarWavesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
