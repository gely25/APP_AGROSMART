import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConnectionBadge extends StatelessWidget {
  final bool connected;

  const ConnectionBadge({super.key, required this.connected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: connected
            ? AppColors.success.withOpacity(0.12)
            : AppColors.destructive.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            size: 14,
            color: connected ? AppColors.success : AppColors.destructive,
          ),
          const SizedBox(width: 5),
          Text(
            connected ? 'En línea' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: connected ? AppColors.success : AppColors.destructive,
            ),
          ),
        ],
      ),
    );
  }
}
