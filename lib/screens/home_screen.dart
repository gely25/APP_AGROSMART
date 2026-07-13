import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
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
        return Scaffold(
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
                              provider.state.connected ? 'ESP32 conectado' : 'Sin conexión',
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

class _TabItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _TabItem(this.activeIcon, this.icon, this.label);
}
