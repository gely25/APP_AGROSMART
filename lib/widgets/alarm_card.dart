import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Animated alarm card — matches the React AlarmCard component.
/// Shows a pulsing red card when alarm is active, a calm green card when silent.
class AlarmCard extends StatefulWidget {
  final bool alarmActive;
  final VoidCallback onSilence;

  const AlarmCard({
    super.key,
    required this.alarmActive,
    required this.onSilence,
  });

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (widget.alarmActive) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AlarmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alarmActive && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.alarmActive) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) {
        final shadowOpacity = widget.alarmActive
            ? 0.2 + _pulseAnim.value * 0.3
            : 0.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.alarmActive
                ? AppColors.destructive
                : const Color(0x0A3D8B5E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.alarmActive
                  ? AppColors.destructive
                  : const Color(0x403D8B5E),
              width: 1,
            ),
            boxShadow: widget.alarmActive
                ? [
                    BoxShadow(
                      color: AppColors.destructive.withOpacity(shadowOpacity),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.alarmActive
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0x1F3D8B5E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.alarmActive
                    ? _WiggleIcon()
                    : const Icon(Icons.shield_outlined,
                        color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alarma del corral',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: widget.alarmActive
                            ? Colors.white70
                            : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.alarmActive ? 'Alarma activada' : 'Sin alertas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.alarmActive
                            ? Colors.white
                            : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              // Silence button
              if (widget.alarmActive)
                GestureDetector(
                  onTap: widget.onSilence,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.notifications_off_outlined,
                            size: 16, color: AppColors.destructive),
                        SizedBox(width: 6),
                        Text(
                          'Silenciar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.destructive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Bell icon that wiggles left-right (matches React wiggle animation)
class _WiggleIcon extends StatefulWidget {
  @override
  State<_WiggleIcon> createState() => _WiggleIconState();
}

class _WiggleIconState extends State<_WiggleIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rot;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _rot = Tween<double>(begin: -0.22, end: 0.22).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rot,
      builder: (_, child) => Transform.rotate(
        angle: _rot.value,
        child: child,
      ),
      child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
    );
  }
}
