import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'all'; // 'all', 'unread', 'read'

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final all = provider.state.notifications;
        final unread = all.where((n) => !n.isRead).toList();
        final read = all.where((n) => n.isRead).toList();

        final filtered = _filter == 'unread'
            ? unread
            : _filter == 'read'
                ? read
                : all;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.card,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.foreground),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.foreground),
                ),
                const SizedBox(width: 8),
                if (unread.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${unread.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            actions: [
              if (unread.isNotEmpty)
                TextButton.icon(
                  onPressed: provider.markAllRead,
                  icon: const Icon(Icons.done_all_rounded, size: 14, color: AppColors.primary),
                  label: const Text(
                    'Leer todas',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary bar
              if (all.isNotEmpty) ...[
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _SummaryPill(
                        label: 'Total',
                        count: all.length,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _SummaryPill(
                        label: 'Sin leer',
                        count: unread.length,
                        color: unread.isEmpty ? AppColors.mutedForeground : AppColors.destructive,
                      ),
                      const SizedBox(width: 8),
                      _SummaryPill(
                        label: 'Leídas',
                        count: read.length,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ],

              // Filter bar
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        count: all.length,
                        value: 'all',
                        current: _filter,
                        onTap: (v) => setState(() => _filter = v),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'No leídas',
                        count: unread.length,
                        value: 'unread',
                        current: _filter,
                        onTap: (v) => setState(() => _filter = v),
                        accentColor: AppColors.destructive,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Leídas',
                        count: read.length,
                        value: 'read',
                        current: _filter,
                        onTap: (v) => setState(() => _filter = v),
                        accentColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),

              Container(height: 1, color: AppColors.border),

              // Notification list
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(filter: _filter)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NotifCard(
                            notif: filtered[i],
                            onTap: () => provider.markNotifRead(filtered[i].id),
                          ),
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

// ── Summary Pill ──────────────────────────────────────────────────────────────

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  IconData get _icon {
    switch (notif.type) {
      case NotificationType.motion:           return Icons.sensors_rounded;
      case NotificationType.waterLow:         return Icons.water_drop_outlined;
      case NotificationType.esp32Disconnected: return Icons.wifi_off_rounded;
      case NotificationType.esp32Reconnected:  return Icons.wifi_rounded;
      case NotificationType.doorOpened:       return Icons.lock_open_rounded;
      case NotificationType.doorClosed:       return Icons.lock_rounded;
      case NotificationType.waterFilled:      return Icons.water_drop_rounded;
      case NotificationType.incident:         return Icons.report_rounded;
    }
  }

  Color get _color {
    switch (notif.type) {
      case NotificationType.motion:           return AppColors.warning;
      case NotificationType.waterLow:         return AppColors.destructive;
      case NotificationType.esp32Disconnected: return AppColors.destructive;
      case NotificationType.esp32Reconnected:  return AppColors.success;
      case NotificationType.doorOpened:       return AppColors.info;
      case NotificationType.doorClosed:       return AppColors.primary;
      case NotificationType.waterFilled:      return AppColors.info;
      case NotificationType.incident:         return AppColors.destructive;
    }
  }

  String get _typeLabel {
    switch (notif.type) {
      case NotificationType.motion:           return 'Sensor PIR';
      case NotificationType.waterLow:         return 'Bebedero';
      case NotificationType.esp32Disconnected: return 'Conectividad';
      case NotificationType.esp32Reconnected:  return 'Conectividad';
      case NotificationType.doorOpened:       return 'Puerta';
      case NotificationType.doorClosed:       return 'Puerta';
      case NotificationType.waterFilled:      return 'Bebedero';
      case NotificationType.incident:         return 'Incidente';
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeStr;
    try {
      timeStr = DateFormat('HH:mm · dd MMM', 'es').format(notif.at);
    } catch (_) {
      timeStr = DateFormat('HH:mm · dd MMM').format(notif.at);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.card : _color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? AppColors.border : _color.withValues(alpha: 0.3),
            width: notif.isRead ? 1 : 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_icon, size: 20, color: _color),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: type label + timestamp + unread dot
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _typeLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _timeAgo(notif.at),
                          style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground),
                        ),
                        if (!notif.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Title
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Message
                    Text(
                      notif.message,
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Footer
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 10, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            timeStr,
                            style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notif.isRead)
                          Text(
                            'Toca para marcar leída',
                            style: TextStyle(
                              fontSize: 9,
                              color: _color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inSeconds < 60) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final String value;
  final String current;
  final void Function(String) onTap;
  final Color? accentColor;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.value,
    required this.current,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    final color = active ? (accentColor ?? AppColors.primary) : AppColors.mutedForeground;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? (accentColor ?? AppColors.primary).withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? (accentColor ?? AppColors.primary).withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: active
                    ? (accentColor ?? AppColors.primary).withValues(alpha: 0.2)
                    : AppColors.muted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? color : AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final msg = filter == 'unread'
        ? 'Sin notificaciones no leídas'
        : filter == 'read'
            ? 'Sin notificaciones leídas'
            : 'Sin notificaciones';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 32, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.foreground),
          ),
          const SizedBox(height: 6),
          const Text(
            'Las alertas del sistema aparecerán aquí',
            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
