import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';
import 'home_screen.dart';
import 'agregar_corral_wizard.dart';

class CorralesScreen extends StatefulWidget {
  const CorralesScreen({super.key});

  @override
  State<CorralesScreen> createState() => _CorralesScreenState();
}

class _CorralesScreenState extends State<CorralesScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final corrales = provider.corrales
            .where((c) =>
                c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            toolbarHeight: 64,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/smartfarm_logo.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('SmartFarm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Mis corrales', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  const Spacer(),
                  _UnreadBadge(count: provider.unreadCount),
                  const SizedBox(width: 4),
                  _AppBarAction(
                    icon: Icons.person_outline_rounded,
                    onTap: () => _showProfile(context, provider),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Buscar corral...',
                              hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                              prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.mutedForeground),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _AddButton(onTap: () => _openWizard(context)),
                    ],
                  ),
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _StatChip(
                        label: '${corrales.length} corral${corrales.length != 1 ? "es" : ""}',
                        icon: Icons.cabin_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: '${corrales.where((c) => c.availability > 90).length} en línea',
                        icon: Icons.wifi_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),

              if (corrales.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(onAdd: () => _openWizard(context)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CorralCard(
                          corral: corrales[i],
                          state: provider.state,
                          onEnter: () {
                            provider.selectCorral(corrales[i].id);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          },
                          onDelete: () => _confirmDelete(context, provider, corrales[i].id),
                        ),
                      ),
                      childCount: corrales.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openWizard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AgregarCorralWizard()),
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: const Text('Eliminar corral', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text('¿Estás seguro de eliminar este corral? Esta acción no se puede deshacer.',
            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
            onPressed: () {
              provider.deleteCorral(id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showProfile(BuildContext context, FarmProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'O',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(provider.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Text('Operador', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  provider.logout();
                },
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text('Cerrar sesión'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Corral Card ─────────────────────────────────────────────────────────────

class _CorralCard extends StatelessWidget {
  final CorralInfo corral;
  final FarmState state;
  final VoidCallback onEnter;
  final VoidCallback onDelete;

  const _CorralCard({
    required this.corral,
    required this.state,
    required this.onEnter,
    required this.onDelete,
  });

  Color get _rssiColor {
    if (corral.rssi > -65) return AppColors.success;
    if (corral.rssi > -80) return AppColors.warning;
    return AppColors.destructive;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final syncAgo = now.difference(state.lastUpdate).inSeconds;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status dot
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: state.connected ? AppColors.successBg : AppColors.destructiveBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.cabin_rounded,
                    color: state.connected ? AppColors.success : AppColors.destructive,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(corral.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                      const SizedBox(height: 2),
                      Text(corral.description,
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: state.connected ? AppColors.successBg : AppColors.destructiveBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: state.connected ? AppColors.success.withOpacity(0.3) : AppColors.destructive.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: state.connected ? AppColors.success : AppColors.destructive,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        state.connected ? 'En línea' : 'Desconectado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: state.connected ? AppColors.success : AppColors.destructive,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: AppColors.border),
          ),

          // Grid of data
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _DataCell(label: 'ESP32', value: corral.macAddress.split(':').take(3).join(':') + '...', icon: Icons.memory_rounded),
                    _DataCell(label: 'Firmware', value: corral.firmware, icon: Icons.system_update_alt_rounded),
                    _DataCell(label: 'RSSI', value: '${corral.rssi}dBm', icon: Icons.wifi_rounded, valueColor: _rssiColor),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _DataCell(label: 'Disponibilidad', value: '${corral.availability.toStringAsFixed(1)}%', icon: Icons.timelapse_rounded),
                    _DataCell(label: 'Eventos hoy', value: '${state.pirEventsToday}', icon: Icons.bolt_rounded),
                    _DataCell(label: 'Sincronización', value: syncAgo < 10 ? 'Ahora' : 'Hace ${syncAgo}s', icon: Icons.sync_rounded),
                  ],
                ),
              ],
            ),
          ),

          // Footer actions
          Container(
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.mutedForeground),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  tooltip: 'Eliminar corral',
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onEnter,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                  label: const Text('Entrar al corral'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DataCell({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: AppColors.mutedForeground),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.foreground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Supporting Widgets ───────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarAction({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.foreground),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});
  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: AppColors.destructive,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.cabin_outlined, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('Sin corrales registrados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Agrega tu primer corral para comenzar',
              style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Agregar corral'),
          ),
        ],
      ),
    );
  }
}
