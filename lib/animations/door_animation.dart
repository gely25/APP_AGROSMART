import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/farm_state.dart';

const _duration = Duration(milliseconds: 1000);

enum _Phase { closed, opening, open, closing }

/// Animated door widget — mirrors the React DoorModule SVG scene.
/// Uses Transform Matrix4 rotateY to simulate 3-D hinge swing.
class DoorAnimation extends StatefulWidget {
  final DoorState doorState;

  const DoorAnimation({super.key, required this.doorState});

  @override
  State<DoorAnimation> createState() => _DoorAnimationState();
}

class _DoorAnimationState extends State<DoorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _angle; // 0 = closed, π/2 ≈ open
  _Phase _phase = _Phase.closed;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _angle = Tween<double>(begin: 0.0, end: -1.52).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.doorState == DoorState.open) {
      _ctrl.value = 1.0;
      _phase = _Phase.open;
    }
  }

  @override
  void didUpdateWidget(DoorAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doorState == widget.doorState) return;

    if (widget.doorState == DoorState.open) {
      setState(() => _phase = _Phase.opening);
      _ctrl.forward().then((_) {
        if (mounted) setState(() => _phase = _Phase.open);
      });
    } else {
      setState(() => _phase = _Phase.closing);
      _ctrl.reverse().then((_) {
        if (mounted) setState(() => _phase = _Phase.closed);
      });
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
        child: AnimatedBuilder(
          animation: _angle,
          builder: (_, __) => Stack(
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
                bottom: 0, left: 0, right: 0, height: 96,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [AppColors.grass1, AppColors.grass2],
                    ),
                  ),
                ),
              ),
              // Grass divider
              Positioned(
                bottom: 96, left: 0, right: 0, height: 10,
                child: Container(color: AppColors.grass3),
              ),
              // Left fence
              Positioned(
                bottom: 64,
                left: 0,
                child: _Fence(right: false),
              ),
              // Right fence
              Positioned(
                bottom: 64,
                right: 0,
                child: _Fence(right: true),
              ),
              // Ground shadow cast by gate
              Positioned(
                bottom: 56,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Transform(
                      alignment: Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..scale(0.18 + (1 - _angle.value.abs() / 1.52) * 0.82, 1.0),
                      child: Container(
                        width: 152,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.black.withOpacity(0.20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Gate — 3D swing via Transform
              Positioned(
                bottom: 64,
                child: LayoutBuilder(
                  builder: (ctx, constraints) => Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(_angle.value),
                    child: const _Gate(),
                  ),
                ),
              ),
              // Hinge post (left of doorway)
              Positioned(
                bottom: 64,
                left: 0,
                child: _Post(),
              ),
              // Latch post (right of doorway)
              Positioned(
                bottom: 64,
                right: 0,
                child: _Post(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fence extends StatelessWidget {
  final bool right;
  const _Fence({required this.right});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        children: [
          // Top rail
          Positioned(top: 12, left: 0, right: 0, height: 8,
            child: Container(decoration: BoxDecoration(
              color: AppColors.wood, borderRadius: BorderRadius.circular(4),
            ))),
          // Bottom rail
          Positioned(bottom: 12, left: 0, right: 0, height: 8,
            child: Container(decoration: BoxDecoration(
              color: AppColors.wood, borderRadius: BorderRadius.circular(4),
            ))),
          // Post 1
          Positioned(left: 20, top: 0, bottom: 0, width: 8,
            child: Container(decoration: BoxDecoration(
              color: AppColors.woodDark, borderRadius: BorderRadius.circular(4),
            ))),
          // Post 2
          Positioned(right: 20, top: 0, bottom: 0, width: 8,
            child: Container(decoration: BoxDecoration(
              color: AppColors.woodDark, borderRadius: BorderRadius.circular(4),
            ))),
        ],
      ),
    );
  }
}

class _Post extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10, height: 96,
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
      width: 152, height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFCAA477), Color(0xFFB98F5F)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7C858D), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          // Inner frame
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0x808B939B), width: 2),
              ),
            ),
          ),
          // Wooden planks
          Positioned(
            left: 6, right: 6, top: 6, bottom: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (_) => Container(
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xA0A67C52),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
          // Diagonal brace
          Positioned(
            left: 8, right: 8, top: 8, bottom: 8,
            child: ClipRect(
              child: Transform.rotate(
                angle: -0.59,
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xCC9AA3AB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          // Hinges (left)
          Positioned(top: 8, left: -4,
            child: Container(width: 8, height: 10,
              decoration: BoxDecoration(color: const Color(0xFF6B7178),
                borderRadius: BorderRadius.circular(2)))),
          Positioned(bottom: 8, left: -4,
            child: Container(width: 8, height: 10,
              decoration: BoxDecoration(color: const Color(0xFF6B7178),
                borderRadius: BorderRadius.circular(2)))),
          // Latch handle (right)
          Positioned(right: -4,
            top: 0, bottom: 0,
            child: Center(child: Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: Color(0xFF5C626A), shape: BoxShape.circle)))),
        ],
      ),
    );
  }
}
