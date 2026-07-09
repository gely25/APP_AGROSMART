import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/farm_state.dart';

/// Animated water trough — mirrors the React WaterModule scene.
class WaterAnimation extends StatefulWidget {
  final WaterState waterState;

  const WaterAnimation({super.key, required this.waterState});

  @override
  State<WaterAnimation> createState() => _WaterAnimationState();
}

class _WaterAnimationState extends State<WaterAnimation>
    with TickerProviderStateMixin {
  late AnimationController _levelCtrl;
  late Animation<double> _level; // 0.0–1.0

  late AnimationController _valveCtrl;
  late AnimationController _surfaceCtrl;
  late Animation<double> _surface;

  double _targetLevel = 0.04;

  @override
  void initState() {
    super.initState();

    _levelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _level = Tween<double>(begin: 0.04, end: 0.04).animate(
      CurvedAnimation(parent: _levelCtrl, curve: Curves.easeInOut),
    );

    _valveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _surfaceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _surface = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _surfaceCtrl, curve: Curves.easeInOut),
    );

    _applyState(widget.waterState, animate: false);
  }

  @override
  void didUpdateWidget(WaterAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waterState != widget.waterState) {
      _applyState(widget.waterState, animate: true);
    }
  }

  void _applyState(WaterState state, {required bool animate}) {
    double newTarget;
    switch (state) {
      case WaterState.full:    newTarget = 0.82; break;
      case WaterState.filling: newTarget = 0.50; break;
      case WaterState.empty:   newTarget = 0.04; break;
    }

    if (state == WaterState.filling) {
      _valveCtrl.repeat();
    } else {
      _valveCtrl.stop();
      _valveCtrl.reset();
    }

    if (animate) {
      _level = Tween<double>(begin: _level.value, end: newTarget).animate(
        CurvedAnimation(parent: _levelCtrl, curve: Curves.easeInOut),
      );
      _levelCtrl
        ..reset()
        ..forward();
    } else {
      _levelCtrl.value = 1.0;
      _level = AlwaysStoppedAnimation(newTarget);
    }
  }

  @override
  void dispose() {
    _levelCtrl.dispose();
    _valveCtrl.dispose();
    _surfaceCtrl.dispose();
    super.dispose();
  }

  bool get _isFilling => widget.waterState == WaterState.filling;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 192,
        child: AnimatedBuilder(
          animation: Listenable.merge([_level, _surface, _valveCtrl]),
          builder: (_, __) => Stack(
            children: [
              // Sky
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.sky1, AppColors.sky2],
                  ),
                ),
              ),
              // Grass
              Positioned(bottom: 0, left: 0, right: 0, height: 64,
                child: Container(decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.grass1, AppColors.grass2],
                  ),
                ))),
              Positioned(bottom: 64, left: 0, right: 0, height: 10,
                child: Container(color: AppColors.grass3)),

              // Supply pipe (top-right)
              Positioned(top: 0, right: 40,
                child: Container(width: 12, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [AppColors.metal, AppColors.metalLight],
                    ),
                    border: Border.all(color: const Color(0xFF8B939B), width: 1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4),
                    ),
                  ))),

              // Elbow pipe (horizontal)
              Positioned(top: 44, right: 32,
                child: Container(width: 40, height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.metalLight,
                    border: Border.all(color: const Color(0xFF8B939B), width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ))),

              // Valve wheel
              Positioned(top: 32, right: 46,
                child: Transform.rotate(
                  angle: _valveCtrl.value * 2 * pi,
                  child: Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.metalLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF8B939B), width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(width: 12, height: 2, color: const Color(0xFF6B7178)),
                        Container(width: 2, height: 12, color: const Color(0xFF6B7178)),
                      ],
                    ),
                  ),
                )),

              // Water stream while filling
              if (_isFilling)
                Positioned(top: 58, right: 40,
                  child: _WaterStream()),

              // Trough legs
              Positioned(bottom: 12,
                child: SizedBox(width: 208,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 8),
                      Container(width: 8, height: 48,
                        decoration: BoxDecoration(color: AppColors.metal,
                          borderRadius: BorderRadius.circular(4))),
                      Container(width: 8, height: 48,
                        decoration: BoxDecoration(color: AppColors.metal,
                          borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 8),
                    ],
                  ))),

              // Trough basin
              Positioned(bottom: 24,
                child: _Trough(
                  level: _level.value,
                  isFilling: _isFilling,
                  surfaceAnim: _surface.value,
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterStream extends StatefulWidget {
  @override
  State<_WaterStream> createState() => _WaterStreamState();
}

class _WaterStreamState extends State<_WaterStream>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Opacity(
            opacity: ((sin(_ctrl.value * pi + i * 0.8) * 0.5 + 0.5)).clamp(0.0, 1.0),
            child: child,
          ),
          child: Container(
            width: 6, height: 12,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.waterColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

class _Trough extends StatelessWidget {
  final double level;
  final bool isFilling;
  final double surfaceAnim;

  const _Trough({
    required this.level,
    required this.isFilling,
    required this.surfaceAnim,
  });

  @override
  Widget build(BuildContext context) {
    const troughHeight = 96.0;
    const troughWidth = 208.0;

    return Container(
      width: troughWidth, height: troughHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFDFE6EA), Color(0xFFB9C3CA)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32),
          topLeft: Radius.circular(10), topRight: Radius.circular(10),
        ),
        border: Border.all(color: AppColors.metal, width: 4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Water body
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: troughHeight * level,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    AppColors.waterColor.withOpacity(0.6),
                    AppColors.waterColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Shimmering surface
                  Positioned(top: 0, left: 0, right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isFilling ? 6 + surfaceAnim * 3 : 6,
                      color: AppColors.waterColor.withOpacity(0.3 + surfaceAnim * 0.2),
                    )),
                  // Bubbles while filling
                  if (isFilling)
                    ...List.generate(5, (i) => Positioned(
                      bottom: 4,
                      left: (0.12 + i * 0.18) * troughWidth,
                      child: _Bubble(delay: i * 130),
                    )),
                ],
              ),
            ),
          ),
          // Level marks (right side)
          Positioned(top: 8, bottom: 8, right: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (_) => Container(
                width: 12, height: 1,
                color: const Color(0xFF5C626A).withOpacity(0.3),
              )),
            )),
        ],
      ),
    );
  }
}

class _Bubble extends StatefulWidget {
  final int delay;
  const _Bubble({required this.delay});

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.3 + _anim.value * 0.2),
        ),
      ),
    );
  }
}
