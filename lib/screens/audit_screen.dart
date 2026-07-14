import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  String _filter = 'today';
  String _searchQuery = '';
  AuditEventType? _typeFilter;
  bool? _successFilter;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AuditEvent> _applyFilters(List<AuditEvent> events) {
    final now = DateTime.now();
    return events.where((e) {
      // Time filter
      if (_filter == 'today') {
        if (e.at.day != now.day || e.at.month != now.month) return false;
      } else if (_filter == 'week') {
        if (now.difference(e.at).inDays > 7) return false;
      }
      // Type filter
      if (_typeFilter != null && e.type != _typeFilter) return false;
      // Success filter
      if (_successFilter != null && e.success != _successFilter) return false;
      // Search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!e.action.toLowerCase().contains(q) &&
            !e.detail.toLowerCase().contains(q) &&
            !e.user.toLowerCase().contains(q) &&
            !(e.corral?.toLowerCase().contains(q) ?? false) &&
            !(e.device?.toLowerCase().contains(q) ?? false)) return false;
      }
      return true;
    }).toList();
  }

  void _simulateExport(BuildContext context, List<AuditEvent> events) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.card,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Exportando ${events.length} registros...', style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('${events.length} registros exportados a auditoria_${DateFormat("yyyyMMdd_HHmm").format(DateTime.now())}.csv')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final filtered = _applyFilters(provider.state.auditLog);

        return Column(
          children: [
            // Toolbar
            _AuditToolbar(
              filter: _filter,
              typeFilter: _typeFilter,
              successFilter: _successFilter,
              searchCtrl: _searchCtrl,
              onFilterChange: (v) => setState(() => _filter = v),
              onTypeChange: (v) => setState(() => _typeFilter = v),
              onSuccessChange: (v) => setState(() => _successFilter = v),
              onSearchChange: (v) => setState(() => _searchQuery = v),
              eventCount: filtered.length,
              onExport: () => _simulateExport(context, filtered),
            ),

            // Summary strip
            if (filtered.isNotEmpty) _AuditSummaryStrip(events: filtered),

            // Timeline
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyAudit()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _AuditTimelineItem(
                        event: filtered[i],
                        isLast: i == filtered.length - 1,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Summary Strip ─────────────────────────────────────────────────────────────

class _AuditSummaryStrip extends StatelessWidget {
  final List<AuditEvent> events;
  const _AuditSummaryStrip({required this.events});

  @override
  Widget build(BuildContext context) {
    final success = events.where((e) => e.success).length;
    final failed = events.length - success;
    final byDoor = events.where((e) => e.type == AuditEventType.door).length;
    final byWater = events.where((e) => e.type == AuditEventType.water).length;
    final byPir = events.where((e) => e.type == AuditEventType.pir).length;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SummaryTile(label: 'Total', count: events.length, color: AppColors.info),
            const SizedBox(width: 8),
            _SummaryTile(label: 'Exitosos', count: success, color: AppColors.success),
            const SizedBox(width: 8),
            _SummaryTile(label: 'Fallidos', count: failed, color: AppColors.destructive),
            const SizedBox(width: 8),
            _SummaryTile(label: 'Puerta', count: byDoor, color: AppColors.info),
            const SizedBox(width: 8),
            _SummaryTile(label: 'Agua', count: byWater, color: const Color(0xFF3B6FD4)),
            const SizedBox(width: 8),
            _SummaryTile(label: 'PIR', count: byPir, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryTile({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

// ── Toolbar ──────────────────────────────────────────────────────────────────

class _AuditToolbar extends StatelessWidget {
  final String filter;
  final AuditEventType? typeFilter;
  final bool? successFilter;
  final TextEditingController searchCtrl;
  final void Function(String) onFilterChange;
  final void Function(AuditEventType?) onTypeChange;
  final void Function(bool?) onSuccessChange;
  final void Function(String) onSearchChange;
  final int eventCount;
  final VoidCallback onExport;

  const _AuditToolbar({
    required this.filter,
    required this.typeFilter,
    required this.successFilter,
    required this.searchCtrl,
    required this.onFilterChange,
    required this.onTypeChange,
    required this.onSuccessChange,
    required this.onSearchChange,
    required this.eventCount,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Search
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearchChange,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar eventos, dispositivos o usuarios...',
                hintStyle: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.mutedForeground),
                suffixText: '$eventCount eventos',
                suffixStyle: const TextStyle(fontSize: 10, color: AppColors.mutedForeground),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Hoy', value: 'today', current: filter, onTap: onFilterChange),
                const SizedBox(width: 6),
                _FilterChip(label: 'Semana', value: 'week', current: filter, onTap: onFilterChange),
                const SizedBox(width: 6),
                _FilterChip(label: 'Todo', value: 'all', current: filter, onTap: onFilterChange),
                const SizedBox(width: 12),
                _TypeChip(label: 'Puerta', value: AuditEventType.door, current: typeFilter, onTap: onTypeChange),
                const SizedBox(width: 6),
                _TypeChip(label: 'Agua', value: AuditEventType.water, current: typeFilter, onTap: onTypeChange),
                const SizedBox(width: 6),
                _TypeChip(label: 'PIR', value: AuditEventType.pir, current: typeFilter, onTap: onTypeChange),
                const SizedBox(width: 6),
                _TypeChip(label: 'Sistema', value: AuditEventType.system, current: typeFilter, onTap: onTypeChange),
                const SizedBox(width: 10),
                // Success/Failed filter
                _SuccessChip(label: 'Exitoso', value: true, current: successFilter, onTap: onSuccessChange),
                const SizedBox(width: 6),
                _SuccessChip(label: 'Fallido', value: false, current: successFilter, onTap: onSuccessChange),
                const SizedBox(width: 10),
                // Export button
                GestureDetector(
                  onTap: onExport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.download_rounded, size: 12, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Exportar CSV', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ],
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

class _TypeChip extends StatelessWidget {
  final String label;
  final AuditEventType value;
  final AuditEventType? current;
  final void Function(AuditEventType?) onTap;
  const _TypeChip({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(active ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.info.withOpacity(0.12) : AppColors.muted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.info.withOpacity(0.4) : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: active ? AppColors.info : AppColors.mutedForeground,
        )),
      ),
    );
  }
}

class _SuccessChip extends StatelessWidget {
  final String label;
  final bool value;
  final bool? current;
  final void Function(bool?) onTap;
  const _SuccessChip({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    final color = value ? AppColors.success : AppColors.destructive;
    return GestureDetector(
      onTap: () => onTap(active ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : AppColors.muted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color.withOpacity(0.4) : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: active ? color : AppColors.mutedForeground,
        )),
      ),
    );
  }
}

// ── Timeline Item ─────────────────────────────────────────────────────────────

class _AuditTimelineItem extends StatelessWidget {
  final AuditEvent event;
  final bool isLast;
  const _AuditTimelineItem({required this.event, required this.isLast});

  Color get _typeColor {
    switch (event.type) {
      case AuditEventType.door: return AppColors.info;
      case AuditEventType.water: return const Color(0xFF3B6FD4);
      case AuditEventType.pir: return AppColors.warning;
      case AuditEventType.alarm: return AppColors.destructive;
      case AuditEventType.automation: return AppColors.primary;
      case AuditEventType.user: return AppColors.primary;
      case AuditEventType.network: return AppColors.info;
      case AuditEventType.system: return AppColors.mutedForeground;
    }
  }

  IconData get _typeIcon {
    switch (event.type) {
      case AuditEventType.door: return Icons.door_front_door_outlined;
      case AuditEventType.water: return Icons.water_drop_outlined;
      case AuditEventType.pir: return Icons.sensors_rounded;
      case AuditEventType.alarm: return Icons.notifications_rounded;
      case AuditEventType.automation: return Icons.auto_fix_high_rounded;
      case AuditEventType.user: return Icons.person_outline_rounded;
      case AuditEventType.network: return Icons.wifi_rounded;
      case AuditEventType.system: return Icons.settings_rounded;
    }
  }

  Color get _originColor {
    switch (event.origin) {
      case 'Manual': return AppColors.info;
      case 'Automático': return AppColors.success;
      case 'HITL': return AppColors.warning;
      case 'Sensor': return AppColors.primary;
      default: return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss').format(event.at);
    final dateStr = DateFormat('dd/MM').format(event.at);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: _typeColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Icon(_typeIcon, size: 12, color: _typeColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
                if (isLast) const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: event.success ? AppColors.border : AppColors.destructive.withOpacity(0.3),
                    width: event.success ? 1 : 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Expanded(
                          child: Text(event.action,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                        ),
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: event.success ? AppColors.success : AppColors.destructive,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(timeStr,
                            style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontFamily: 'monospace')),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Detail
                    Text(event.detail,
                        style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                    const SizedBox(height: 8),

                    // Extended info grid
                    if (event.corral != null || event.device != null || event.result != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (event.corral != null) ...[
                              _MiniField(icon: Icons.fence_rounded, label: event.corral!),
                              const SizedBox(width: 8),
                            ],
                            if (event.device != null) ...[
                              _MiniField(icon: Icons.device_hub_rounded, label: event.device!),
                              const SizedBox(width: 8),
                            ],
                            if (event.result != null)
                              _MiniField(
                                icon: event.success ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                                label: event.result!,
                                color: event.success ? AppColors.success : AppColors.destructive,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Footer chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _AuditChip(label: dateStr, icon: Icons.calendar_today_outlined, color: AppColors.mutedForeground),
                          const SizedBox(width: 6),
                          _AuditChip(label: event.user, icon: Icons.person_outline_rounded, color: AppColors.mutedForeground),
                          const SizedBox(width: 6),
                          _AuditChip(label: event.origin, icon: Icons.source_rounded, color: _originColor),
                          if (event.duration != null) ...[
                            const SizedBox(width: 6),
                            _AuditChip(
                              label: _formatDuration(event.duration!),
                              icon: Icons.timer_outlined,
                              color: AppColors.mutedForeground,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }
}

class _MiniField extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniField({required this.icon, required this.label, this.color = AppColors.mutedForeground});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _AuditChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _AuditChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _EmptyAudit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.history_rounded, size: 28, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 14),
          const Text('Sin eventos registrados', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Los eventos de auditoría aparecerán aquí',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
