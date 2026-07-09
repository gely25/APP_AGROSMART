import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/connection_badge.dart';
import 'dashboard_screen.dart';
import 'control_screen.dart';
import 'realtime_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _titles = [
    'Dashboard',
    'Control del corral',
    'Estado en tiempo real',
    'Información',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            toolbarHeight: 64,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/smartfarm_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('SmartFarm',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground,
                          )),
                        Text(
                          _titles[_tab],
                          style: const TextStyle(
                            fontSize: 11, color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ConnectionBadge(connected: provider.state.connected),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),

          // Body — IndexedStack preserves state between tabs
          body: IndexedStack(
            index: _tab,
            children: const [
              DashboardScreen(),
              ControlScreen(),
              RealtimeScreen(),
              InfoScreen(),
            ],
          ),

          // Bottom navigation bar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildNavItems(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildNavItems() {
    final items = [
      (Icons.grid_view_rounded, Icons.grid_view_outlined, 'Inicio'),
      (Icons.tune_rounded, Icons.tune_outlined, 'Control'),
      (Icons.monitor_heart_rounded, Icons.monitor_heart_outlined, 'Tiempo real'),
      (Icons.info_rounded, Icons.info_outlined, 'Info'),
    ];

    return items.indexed.map((entry) {
      final i = entry.$1;
      final item = entry.$2;
      final active = _tab == i;

      return GestureDetector(
        onTap: () => setState(() => _tab = i),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56, height: 32,
              decoration: BoxDecoration(
                color: active ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                active ? item.$1 : item.$2,
                size: 20,
                color: active ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.$3,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
