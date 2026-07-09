import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/status_card.dart';

/// Row widget for the Realtime screen — matches the React Row component.
class RealtimeRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final StatusTone tone;

  const RealtimeRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.tone = StatusTone.neutral,
  });

  @override
  State<RealtimeRow> createState() => _RealtimeRowState();
}

class _RealtimeRowState extends State<RealtimeRow> {
  bool _flash = false;

  @override
  void didUpdateWidget(RealtimeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() => _flash = true);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _flash = false);
      });
    }
  }

  Color get _dotColor {
    switch (widget.tone) {
      case StatusTone.success: return AppColors.success;
      case StatusTone.alert:   return AppColors.destructive;
      case StatusTone.info:    return AppColors.info;
      case StatusTone.neutral: return AppColors.mutedForeground;
    }
  }

  Color get _textColor {
    switch (widget.tone) {
      case StatusTone.success: return AppColors.success;
      case StatusTone.alert:   return AppColors.destructive;
      case StatusTone.info:    return AppColors.info;
      case StatusTone.neutral: return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _flash
          ? AppColors.info.withOpacity(0.10)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, size: 16, color: AppColors.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
          ),
          Text(
            widget.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          const SizedBox(width: 10),
          // Pulsing dot
          _PulsingDot(color: _dotColor, pulse: widget.tone != StatusTone.neutral),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool pulse;

  const _PulsingDot({required this.color, this.pulse = true});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
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
    if (!widget.pulse) {
      return Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
