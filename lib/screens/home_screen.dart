import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';
import '../screens/corrales_screen.dart';
import 'dashboard_screen.dart';
import 'control_screen.dart';
import 'monitoring_screen.dart';
import 'audit_screen.dart';
import 'automation_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _tabs = [
    _TabItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Dashboard'),
    _TabItem(Icons.tune_rounded, Icons.tune_outlined, 'Control'),
    _TabItem(Icons.monitor_heart_rounded, Icons.monitor_heart_outlined, 'Monitoreo'),
    _TabItem(Icons.history_rounded, Icons.history_outlined, 'Auditoría'),
    _TabItem(Icons.auto_fix_high_rounded, Icons.auto_fix_high_outlined, 'Reglas'),
  ];

  static const _pages = [
    DashboardScreen(),
    ControlScreen(),
    MonitoringScreen(),
    AuditScreen(),
    AutomationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final corral = provider.activeCorral;
        return _NotificationOverlay(
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              toolbarHeight: 64,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CorralesScreen()),
                  );
                },
                tooltip: 'Mis corrales',
              ),
              title: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            corral?.name ?? 'Corral',
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: provider.state.connected ? AppColors.success : AppColors.destructive,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                provider.state.connected ? 'Controlador conectado' : 'Sin conexión',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: provider.state.connected ? AppColors.success : AppColors.destructive,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _tabs[_tab].label,
                                style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Notification bell with badge
                    GestureDetector(
                      onTap: () => _openNotifications(context),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.notifications_outlined, size: 18, color: AppColors.foreground),
                          ),
                          if (provider.unreadCount > 0)
                            Positioned(
                              top: -3, right: -3,
                              child: Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.destructive,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    '${provider.unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Settings
                    GestureDetector(
                      onTap: () => _openSettings(context),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.settings_outlined, size: 18, color: AppColors.foreground),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.border),
              ),
            ),
            body: IndexedStack(index: _tab, children: _pages),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _tabs.indexed.map((entry) {
                      final i = entry.$1;
                      final tab = entry.$2;
                      final active = _tab == i;
                      return GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50, height: 30,
                              decoration: BoxDecoration(
                                color: active ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Icon(
                                active ? tab.activeIcon : tab.icon,
                                size: 18,
                                color: active ? AppColors.primary : AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                color: active ? AppColors.primary : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}

// ── Android-style Notification Overlay ───────────────────────────────────────

class _NotificationOverlay extends StatefulWidget {
  final Widget child;
  const _NotificationOverlay({required this.child});

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  AppNotification? _visible;
  String? _lastShownId;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _show(AppNotification notif) async {
    if (_lastShownId == notif.id) return;
    _lastShownId = notif.id;
    setState(() => _visible = notif);
    await _ctrl.forward(from: 0);
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() async {
    await _ctrl.reverse();
    if (mounted) setState(() => _visible = null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        // Find the newest unread notification
        final unread = provider.state.notifications
            .where((n) => !n.isRead)
            .toList();

        if (unread.isNotEmpty) {
          final newest = unread.first;
          if (newest.id != _lastShownId) {
            // Post-frame to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) => _show(newest));
          }
        }

        return Stack(
          children: [
            widget.child,
            if (_visible != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: _NotifBanner(
                      notif: _visible!,
                      onDismiss: () {
                        _dismissTimer?.cancel();
                        provider.markNotifRead(_visible!.id);
                        _dismiss();
                      },
                      onTap: () {
                        _dismissTimer?.cancel();
                        provider.markNotifRead(_visible!.id);
                        _dismiss();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotifBanner extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onDismiss;
  final VoidCallback onTap;
  const _NotifBanner({required this.notif, required this.onDismiss, required this.onTap});

  IconData get _icon {
    switch (notif.type) {
      case NotificationType.motion: return Icons.sensors_rounded;
      case NotificationType.waterLow: return Icons.water_drop_rounded;
      case NotificationType.esp32Disconnected: return Icons.wifi_off_rounded;
      case NotificationType.esp32Reconnected: return Icons.wifi_rounded;
      case NotificationType.doorOpened: return Icons.lock_open_rounded;
      case NotificationType.doorClosed: return Icons.lock_rounded;
      case NotificationType.waterFilled: return Icons.water_drop_outlined;
      case NotificationType.incident: return Icons.report_outlined;
    }
  }

  Color get _color {
    switch (notif.type) {
      case NotificationType.motion: return AppColors.warning;
      case NotificationType.waterLow: return const Color(0xFF3B6FD4);
      case NotificationType.esp32Disconnected: return AppColors.destructive;
      case NotificationType.esp32Reconnected: return AppColors.success;
      case NotificationType.doorOpened: return AppColors.info;
      case NotificationType.doorClosed: return AppColors.mutedForeground;
      case NotificationType.waterFilled: return AppColors.success;
      case NotificationType.incident: return AppColors.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Colored icon
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _color.withValues(alpha: 0.25)),
                ),
                child: Icon(_icon, size: 20, color: _color),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SmartFarm',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _timeAgo(notif.at),
                          style: const TextStyle(fontSize: 9, color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.title,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      notif.message,
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Dismiss button
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded, size: 14, color: AppColors.mutedForeground),
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
    return 'Hace ${diff.inHours}h';
  }
}

class _TabItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _TabItem(this.activeIcon, this.icon, this.label);
}
