import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusTone { success, alert, info, neutral }

class _ToneStyle {
  final Color wrapBorder;
  final Color wrapBg;
  final Color iconBg;
  final Color iconColor;
  final Color dot;
  final Color label;

  const _ToneStyle({
    required this.wrapBorder,
    required this.wrapBg,
    required this.iconBg,
    required this.iconColor,
    required this.dot,
    required this.label,
  });
}

const _toneStyles = {
  StatusTone.success: _ToneStyle(
    wrapBorder: Color(0x403D8B5E),
    wrapBg: Color(0x0A3D8B5E),
    iconBg: Color(0x1F3D8B5E),
    iconColor: AppColors.success,
    dot: AppColors.success,
    label: AppColors.success,
  ),
  StatusTone.alert: _ToneStyle(
    wrapBorder: Color(0x4DD0412D),
    wrapBg: Color(0x0AD0412D),
    iconBg: Color(0x1FD0412D),
    iconColor: AppColors.destructive,
    dot: AppColors.destructive,
    label: AppColors.destructive,
  ),
  StatusTone.info: _ToneStyle(
    wrapBorder: Color(0x403B6FD4),
    wrapBg: Color(0x0A3B6FD4),
    iconBg: Color(0x1F3B6FD4),
    iconColor: AppColors.info,
    dot: AppColors.info,
    label: AppColors.info,
  ),
  StatusTone.neutral: _ToneStyle(
    wrapBorder: AppColors.border,
    wrapBg: AppColors.card,
    iconBg: AppColors.muted,
    iconColor: AppColors.mutedForeground,
    dot: AppColors.mutedForeground,
    label: AppColors.mutedForeground,
  ),
};

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final StatusTone tone;
  final bool pulse;

  const StatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.tone = StatusTone.neutral,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = _toneStyles[tone]!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.wrapBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.wrapBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PulseWrapper(
                pulse: pulse,
                color: s.iconColor,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: s.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: s.iconColor, size: 20),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: s.dot,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: s.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseWrapper extends StatefulWidget {
  final bool pulse;
  final Color color;
  final Widget child;

  const _PulseWrapper({
    required this.pulse,
    required this.color,
    required this.child,
  });

  @override
  State<_PulseWrapper> createState() => _PulseWrapperState();
}

class _PulseWrapperState extends State<_PulseWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) return widget.child;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40 + _anim.value * 14,
            height: 40 + _anim.value * 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.45 * (1 - _anim.value)),
            ),
          ),
          child!,
        ],
      ),
      child: widget.child,
    );
  }
}
