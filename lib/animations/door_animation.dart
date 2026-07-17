import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/farm_state.dart';

const _duration = Duration(milliseconds: 1200);

class DoorAnimation extends StatefulWidget {
  final DoorState doorState;
  // While doorState == DoorState.moving, this says which way it's headed.
  final DoorState? doorTarget;

  const DoorAnimation({super.key, required this.doorState, this.doorTarget});

  @override
  State<DoorAnimation> createState() => _DoorAnimationState();
}

class _DoorAnimationState extends State<DoorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnimation; // 0.0 = closed, 1.0 = open (fully slid left)

  bool get _isHeadedOpen {
    if (widget.doorState == DoorState.moving) {
      return widget.doorTarget == DoorState.open;
    }
    return widget.doorState == DoorState.open;
  }

  @override
  void initState() {
    super.initState();
    // Curves.easeInOutCubic represents a very smooth servo-like motion profile
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );
    if (_isHeadedOpen) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DoorAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldHeadedOpen = oldWidget.doorState == DoorState.moving
        ? oldWidget.doorTarget == DoorState.open
        : oldWidget.doorState == DoorState.open;
    if (oldHeadedOpen == _isHeadedOpen) return;

    if (_isHeadedOpen) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 192,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            const double gateWidth = 152.0;
            final double leftPostPos = (totalWidth - gateWidth) / 2;
            final double rightPostPos = leftPostPos + gateWidth - 10;

            return AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, _) {
                final slideOffset = -gateWidth * _slideAnimation.value;

                return Stack(
                  children: [
                    // Sky gradient
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.sky1, AppColors.sky2],
                          ),
                        ),
                      ),
                    ),
                    // Grass
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 96,
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
                      bottom: 96,
                      left: 0,
                      right: 0,
                      height: 10,
                      child: Container(color: AppColors.grass3),
                    ),

                    // Left fence - spans from 0 to leftPostPos
                    Positioned(
                      bottom: 64,
                      left: 0,
                      width: leftPostPos,
                      child: _ResponsiveFence(width: leftPostPos),
                    ),

                    // Right fence - spans from rightPostPos + 10 to totalWidth
                    Positioned(
                      bottom: 64,
                      left: rightPostPos + 10,
                      width: totalWidth - (rightPostPos + 10),
                      child: _ResponsiveFence(width: totalWidth - (rightPostPos + 10)),
                    ),

                    // Gate clipped to the doorway area
                    Positioned(
                      bottom: 64,
                      left: leftPostPos,
                      width: gateWidth,
                      height: 96,
                      child: ClipRect(
                        child: Transform.translate(
                          offset: Offset(slideOffset, 0),
                          child: const _Gate(),
                        ),
                      ),
                    ),

                    // Hinge post (left of doorway)
                    Positioned(
                      bottom: 64,
                      left: leftPostPos,
                      child: _Post(),
                    ),
                    // Latch post (right of doorway)
                    Positioned(
                      bottom: 64,
                      left: rightPostPos,
                      child: _Post(),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ResponsiveFence extends StatelessWidget {
  final double width;
  const _ResponsiveFence({required this.width});

  @override
  Widget build(BuildContext context) {
    // Generate posts dynamically based on fence width
    final int postCount = (width / 35.0).floor().clamp(1, 10);
    return SizedBox(
      width: width,
      height: 80,
      child: Stack(
        children: [
          // Top rail
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            height: 8,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.wood,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Bottom rail
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            height: 8,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.wood,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Dynamically spaced posts
          ...List.generate(postCount, (i) {
            double leftPos = 10.0;
            if (postCount > 1) {
              leftPos = 5.0 + i * ((width - 15.0) / (postCount - 1));
            }
            return Positioned(
              left: leftPos.clamp(0.0, width - 8.0),
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.woodDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Post extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9AA3AB), Color(0xFFC9D0D6), Color(0xFF7C858D)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      height: 96,
      decoration: BoxDecoration(
        // Color base de madera oscura para el borde exterior/marco principal
        color: const Color(0xFF5A3E25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3E2A18), width: 3),
      ),
      child: Stack(
        children: [
          // Fondo de las tablas (simula las uniones)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF3A2514),
            ),
          ),
          // Tablas horizontales de madera con gradiente y textura individual
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF8B5A2B), // Madera clara
                            Color(0xFF6E471E), // Madera media
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          )
                        ]
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Soporte en diagonal clásico de puerta de establo/corral (Z-brace)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DiagonalBracePainter(),
              ),
            ),
          ),
          // Bisagras reforzadas de hierro forjado negro (Izquierda)
          Positioned(
            top: 12,
            left: -2,
            child: Container(
              width: 16,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: -2,
            child: Container(
              width: 16,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
              ),
            ),
          ),
          // Cerrojo/Manija rústica (Derecha)
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 12,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    )
                  ]
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 8,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor para la barra diagonal clásica de madera
class _DiagonalBracePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A3E25) // Tono del marco
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Definimos un travesaño diagonal desde arriba a la izquierda hacia abajo a la derecha
    const double thickness = 10.0;
    
    // Sombra sutil de la diagonal
    final shadowPath = Path();
    shadowPath.moveTo(12, 4);
    shadowPath.lineTo(size.width - 4, size.height - 12);
    shadowPath.lineTo(size.width - 4, size.height - 12 + thickness);
    shadowPath.lineTo(12, 4 + thickness);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Dibujo principal de la barra
    path.moveTo(10, 4);
    path.lineTo(size.width - 6, size.height - 10);
    path.lineTo(size.width - 6, size.height - 10 - thickness);
    path.lineTo(10, 4 - thickness);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

