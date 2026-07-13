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
        final filtered = all.where((n) {
          if (_filter == 'unread') return !n.isRead;
          if (_filter == 'read') return n.isRead;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Row(
              children: [
                const Text('Notificaciones'),
                const SizedBox(width: 8),
                if (provider.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${provider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            actions: [
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: provider.markAllRead,
                  child: const Text('Leer todas', style: TextStyle(fontSize: 12)),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          body: Column(
            children: [
              // Filter bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.background,
                child: Row(
                  children: [
                    _FilterChip(label: 'Todas (${all.length})', value: 'all', current: _filter,
                        onTap: (v) => setState(() => _filter = v)),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'No leídas', value: 'unread', current: _filter,
                        onTap: (v) => setState(() => _filter = v)),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Leídas', value: 'read', current: _filter,
                        onTap: (v) => setState(() => _filter = v)),
                  ],
                ),
              ),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(filter: _filter)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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

// ── Notification Card ─────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  IconData get _icon {
    switch (notif.type) {
      case NotificationType.motion: return Icons.sensors_rounded;
      case NotificationType.waterLow: return Icons.water_drop_outlined;
      case NotificationType.esp32Disconnected: return Icons.wifi_off_rounded;
      case NotificationType.esp32Reconnected: return Icons.wifi_rounded;
      case NotificationType.doorOpened: return Icons.lock_open_rounded;
      case NotificationType.doorClosed: return Icons.lock_rounded;
      case NotificationType.waterFilled: return Icons.water_drop_rounded;
      case NotificationType.incident: return Icons.report_rounded;
    }
  }

  Color get _color {
    switch (notif.type) {
      case NotificationType.motion: return AppColors.warning;
      case NotificationType.waterLow: return AppColors.destructive;
      case NotificationType.esp32Disconnected: return AppColors.destructive;
      case NotificationType.esp32Reconnected: return AppColors.success;
      case NotificationType.doorOpened: return AppColors.info;
      case NotificationType.doorClosed: return AppColors.primary;
      case NotificationType.waterFilled: return AppColors.info;
      case NotificationType.incident: return AppColors.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm · dd MMM', 'es').format(notif.at);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.card : _color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? AppColors.border : _color.withOpacity(0.3),
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
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, size: 18, color: _color),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notif.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                                color: AppColors.foreground,
                              )),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: _color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.message,
                        style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 10, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text(timeStr, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                        if (!notif.isRead) ...[
                          const SizedBox(width: 10),
                          Text('Toca para marcar como leída',
                              style: TextStyle(fontSize: 10, color: _color, fontWeight: FontWeight.w500)),
                        ],
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
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;
  const _FilterChip({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: active ? Colors.white : AppColors.mutedForeground,
        )),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.notifications_none_rounded, size: 28, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 14),
          Text(
            filter == 'unread' ? 'Sin notificaciones no leídas' : 'Sin notificaciones',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text('Las alertas del sistema aparecerán aquí',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
