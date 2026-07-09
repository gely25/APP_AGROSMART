import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/farm_state.dart';

const _duration = Duration(milliseconds: 1000);

/// Animated feeder/hopper widget — mirrors the React FeederModule scene.
class FeederAnimation extends StatefulWidget {
  final FeederState feederState;

  const FeederAnimation({super.key, required this.feederState});

  @override
  State<FeederAnimation> createState() => _FeederAnimationState();
}

class _FeederAnimationState extends State<FeederAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _lidAngle; // 0 = closed, ~-1.26 (72°) = open
  bool _isPouring = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _lidAngle = Tween<double>(begin: 0.0, end: -1.26).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.feederState == FeederState.open) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FeederAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feederState == widget.feederState) return;

    if (widget.feederState == FeederState.open) {
      setState(() => _isPouring = true);
      _ctrl.forward().then((_) {
        if (mounted) setState(() => _isPouring = false);
      });
    } else {
      setState(() => _isPouring = false);
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isOpen => widget.feederState == FeederState.open || _ctrl.value > 0.01;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 192,
        child: AnimatedBuilder(
          animation: _lidAngle,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
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
              Positioned(bottom: 0, left: 0, right: 0, height: 80,
                child: Container(decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.grass1, AppColors.grass2],
                  ),
                ))),
              Positioned(bottom: 80, left: 0, right: 0, height: 10,
                child: Container(color: AppColors.grass3)),

              // Support legs
              Positioned(bottom: 16, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    _Leg(), const SizedBox(width: 100), _Leg(),
                  ],
                )),

              // Hopper bin
              Positioned(
                top: 32, child: _Hopper()),

              // Hinged lid
              Positioned(
                top: 24,
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_lidAngle.value),
                  child: _Lid(),
                ),
              ),

              // Grain falling (pouring animation)
              if (_isPouring)
                Positioned(top: 88, child: _GrainStream()),

              // Feed trough at base
              Positioned(bottom: 12, child: _Trough(filled: _ctrl.value > 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leg extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 8, height: 64,
        decoration: BoxDecoration(
          color: AppColors.metal,
          borderRadius: BorderRadius.circular(4)));
}

class _Hopper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128, height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.metalLight, AppColors.metal],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8), topRight: Radius.circular(8),
        ),
        border: Border.all(color: const Color(0xFF8B939B), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
      ),
      child: Stack(
        children: [
          // Corrugated ribs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (_) => Container(
              width: 1,
              color: const Color(0x665C626A),
            )),
          ),
          // Grain level
          Positioned(bottom: 0, left: 0, right: 0,
            child: Container(
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppColors.grain, AppColors.grainDark],
                ),
              ),
              child: Wrap(
                children: List.generate(20, (i) => Container(
                  width: 5, height: 5, margin: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA9781F), shape: BoxShape.circle,
                  ),
                )),
              ),
            )),
        ],
      ),
    );
  }
}

class _Lid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 144, height: 16,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFE2E7EB), Color(0xFFAEB6BD)],
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF8B939B), width: 2),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
    ),
    child: Center(
      child: Container(width: 24, height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF6B7178),
          borderRadius: BorderRadius.circular(2),
        )),
    ),
  );
}

class _GrainStream extends StatefulWidget {
  @override
  State<_GrainStream> createState() => _GrainStreamState();
}

class _GrainStreamState extends State<_GrainStream>
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
      children: List.generate(4, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 600 + i * 90),
          builder: (_, v, child) => Opacity(
            opacity: (sin(v * pi + i * 0.8) * 0.5 + 0.5).clamp(0.0, 1.0),
            child: child,
          ),
          child: Container(
            width: 6, height: 6, margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              color: AppColors.grain, shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _Trough extends StatelessWidget {
  final bool filled;
  const _Trough({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176, height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFA9814F), Color(0xFF8A6A45)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
          topLeft: Radius.circular(8), topRight: Radius.circular(8),
        ),
        border: Border.all(color: const Color(0xFF6F5537), width: 1),
      ),
      child: Stack(
        children: [
          Positioned(left: 8, right: 8, top: 6, bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6F5537),
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          // Pellets
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: filled ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              offset: filled ? Offset.zero : const Offset(0, 0.3),
              child: Positioned(left: 12, right: 12, bottom: 8,
                child: Wrap(
                  spacing: 4, runSpacing: 4,
                  children: List.generate(22, (_) => Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.grain, shape: BoxShape.circle,
                    ),
                  )),
                )),
            ),
          ),
        ],
      ),
    );
  }
}
