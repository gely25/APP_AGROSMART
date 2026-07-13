import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        return Column(
          children: [
            // Mode selector card
            _ModeHeaderCard(
              mode: provider.state.operationMode,
              onChanged: provider.setMode,
            ),

            // Tabs
            Container(
              color: AppColors.background,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.mutedForeground,
                indicatorColor: AppColors.primary,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Reglas SI / ENTONCES'),
                  Tab(text: 'Horarios'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _RulesTab(provider: provider),
                  _SchedulesTab(provider: provider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Mode Header ──────────────────────────────────────────────────────────────

class _ModeHeaderCard extends StatelessWidget {
  final OperationMode mode;
  final void Function(OperationMode) onChanged;
  const _ModeHeaderCard({required this.mode, required this.onChanged});

  String get _modeLabel {
    switch (mode) {
      case OperationMode.manual: return 'Manual';
      case OperationMode.automatic: return 'Automático';
      case OperationMode.humanInTheLoop: return 'Human in the Loop (HITL)';
    }
  }

  String get _modeDesc {
    switch (mode) {
      case OperationMode.manual:
        return 'El operador controla todo manualmente. Las reglas no se ejecutan automáticamente.';
      case OperationMode.automatic:
        return 'El sistema ejecuta las reglas automáticamente sin requerir aprobación.';
      case OperationMode.humanInTheLoop:
        return 'El sistema solicita aprobación del operador antes de ejecutar acciones críticas.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_remote_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Modo de operación', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(_modeLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(_modeDesc, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          const SizedBox(height: 12),
          Row(
            children: [
              _ModeBtn(label: 'Manual', icon: Icons.pan_tool_outlined, mode: OperationMode.manual, current: mode, onTap: onChanged),
              const SizedBox(width: 6),
              _ModeBtn(label: 'Auto', icon: Icons.auto_fix_high_outlined, mode: OperationMode.automatic, current: mode, onTap: onChanged),
              const SizedBox(width: 6),
              _ModeBtn(label: 'HITL', icon: Icons.supervised_user_circle_outlined, mode: OperationMode.humanInTheLoop, current: mode, onTap: onChanged),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final OperationMode mode;
  final OperationMode current;
  final void Function(OperationMode) onTap;
  const _ModeBtn({required this.label, required this.icon, required this.mode, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = mode == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.muted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 15, color: active ? Colors.white : AppColors.mutedForeground),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.mutedForeground)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Rules Tab ─────────────────────────────────────────────────────────────────

class _RulesTab extends StatelessWidget {
  final FarmProvider provider;
  const _RulesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Info note
        _InfoNote(
          icon: Icons.info_outline_rounded,
          text: 'Las reglas SI/ENTONCES se evalúan en tiempo real. '
              'En modo HITL, las acciones críticas requieren aprobación del operador.',
          color: AppColors.info,
        ),
        const SizedBox(height: 14),

        // Section label
        const _SectionLabel('REGLAS ACTIVAS'),
        const SizedBox(height: 10),

        // Rules list
        ...provider.rules.map((rule) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RuleCard(rule: rule, provider: provider),
        )),

        const SizedBox(height: 14),

        // Add rule hint
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.mutedForeground),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Crear nueva regla', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                    SizedBox(height: 2),
                    Text('Constructor de reglas personalizadas — próxima versión',
                        style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Text('Próximo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final AutomationRule rule;
  final FarmProvider provider;
  const _RuleCard({required this.rule, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rule.enabled ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          width: rule.enabled ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: rule.enabled ? AppColors.primaryLight : AppColors.muted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_fix_high_rounded,
                      size: 16, color: rule.enabled ? AppColors.primary : AppColors.mutedForeground),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Condition → Action
                      Row(
                        children: [
                          Flexible(
                            child: _ConditionPill(label: 'SI: ${rule.conditionLabel}', color: AppColors.warning),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 10, color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Flexible(
                            child: _ConditionPill(label: 'ENTONCES: ${rule.actionLabel}', color: AppColors.success),
                          ),
                        ],
                      ),
                      if (rule.requiresHITL) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.supervised_user_circle_outlined, size: 10, color: AppColors.warning),
                            SizedBox(width: 4),
                            Text('Requiere aprobación HITL', style: TextStyle(fontSize: 10, color: AppColors.warning)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Toggle
                Switch.adaptive(
                  value: rule.enabled,
                  activeColor: AppColors.primary,
                  onChanged: (_) => provider.toggleRule(rule.id),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.muted.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rule.enabled ? AppColors.success : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 6),
                Text(rule.enabled ? 'Regla activa' : 'Regla desactivada',
                    style: TextStyle(fontSize: 10, color: rule.enabled ? AppColors.success : AppColors.mutedForeground)),
                const Spacer(),
                GestureDetector(
                  onTap: () => provider.toggleRuleHITL(rule.id),
                  child: Text(
                    rule.requiresHITL ? 'Quitar HITL' : 'Activar HITL',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.info),
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

class _ConditionPill extends StatelessWidget {
  final String label;
  final Color color;
  const _ConditionPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
          maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

// ── Schedules Tab ─────────────────────────────────────────────────────────────

class _SchedulesTab extends StatelessWidget {
  final FarmProvider provider;
  const _SchedulesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _InfoNote(
          icon: Icons.schedule_rounded,
          text: 'Los horarios configurados se ejecutan automáticamente según el modo de operación activo.',
          color: AppColors.success,
        ),
        const SizedBox(height: 14),
        const _SectionLabel('HORARIOS CONFIGURADOS'),
        const SizedBox(height: 10),

        ...provider.schedules.map((sch) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ScheduleCard(schedule: sch, provider: provider),
        )),

        const SizedBox(height: 14),
        // Add schedule button
        GestureDetector(
          onTap: () => _showAddScheduleDialog(context, provider),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_alarm_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Agregar horario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddScheduleDialog(BuildContext context, FarmProvider provider) {
    showDialog(
      context: context,
      builder: (_) => _AddScheduleDialog(provider: provider),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final AutomationSchedule schedule;
  final FarmProvider provider;
  const _ScheduleCard({required this.schedule, required this.provider});

  static const _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  String get _actionLabel {
    switch (schedule.action) {
      case 'open_door': return 'Abrir puerta';
      case 'close_door': return 'Cerrar puerta';
      case 'fill_water': return 'Llenar bebedero';
      default: return schedule.action;
    }
  }

  IconData get _actionIcon {
    switch (schedule.action) {
      case 'open_door': return Icons.lock_open_rounded;
      case 'close_door': return Icons.lock_rounded;
      case 'fill_water': return Icons.water_drop_rounded;
      default: return Icons.play_arrow_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.enabled ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          width: schedule.enabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Time
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: schedule.enabled ? AppColors.primaryLight : AppColors.muted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(timeStr, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: schedule.enabled ? AppColors.primary : AppColors.mutedForeground,
                )),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(_actionIcon, size: 11, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(_actionLabel,
                          style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Day chips
                Row(
                  children: List.generate(7, (i) {
                    final active = schedule.days.length > i && schedule.days[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.muted,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(_dayLabels[i],
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : AppColors.mutedForeground)),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Toggle + delete
          Column(
            children: [
              Switch.adaptive(
                value: schedule.enabled,
                activeColor: AppColors.primary,
                onChanged: (_) => provider.toggleSchedule(schedule.id),
              ),
              GestureDetector(
                onTap: () => provider.deleteSchedule(schedule.id),
                child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddScheduleDialog extends StatefulWidget {
  final FarmProvider provider;
  const _AddScheduleDialog({required this.provider});

  @override
  State<_AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<_AddScheduleDialog> {
  final _labelCtrl = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  List<bool> _days = [true, true, true, true, true, false, false];
  String _action = 'open_door';

  static const _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _actions = [
    ('open_door', 'Abrir puerta'),
    ('close_door', 'Cerrar puerta'),
    ('fill_water', 'Llenar bebedero'),
  ];

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.card,
      title: const Text('Nuevo horario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                hintText: 'Ej: Apertura matutina',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            const Text('Hora', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _time);
                if (picked != null) setState(() => _time = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(timeStr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Días', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(7, (i) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _days[i] = !_days[i]),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 32,
                        decoration: BoxDecoration(
                          color: _days[i] ? AppColors.primary : AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(_dayLabels[i],
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                  color: _days[i] ? Colors.white : AppColors.mutedForeground)),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            const Text('Acción', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            ..._actions.map((a) => RadioListTile<String>(
              value: a.$1,
              groupValue: _action,
              title: Text(a.$2, style: const TextStyle(fontSize: 12)),
              activeColor: AppColors.primary,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _action = v!),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            widget.provider.addSchedule(AutomationSchedule(
              id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
              label: _labelCtrl.text.trim().isEmpty ? 'Horario' : _labelCtrl.text.trim(),
              time: _time,
              days: List.from(_days),
              action: _action,
              enabled: true,
            ));
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// ── Shared Helpers ────────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoNote({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 11, color: color.withOpacity(0.85)))),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppColors.mutedForeground));
}
