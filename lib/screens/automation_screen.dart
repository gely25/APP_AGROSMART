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

class _AutomationScreenState extends State<AutomationScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final mode = provider.state.operationMode;
        final isHitl = mode == OperationMode.humanInTheLoop;
        final tabsCount = isHitl ? 3 : 2;

        return DefaultTabController(
          key: ValueKey(mode),
          length: tabsCount,
          child: Column(
            children: [
              // Mode selector card
              _ModeHeaderCard(
                mode: mode,
                onChanged: provider.setMode,
              ),

              // Tabs
              Container(
                color: AppColors.background,
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.mutedForeground,
                  indicatorColor: AppColors.primary,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: [
                    const Tab(text: 'Reglas SI / ENTONCES'),
                    if (isHitl) const Tab(text: 'Umbrales y Parámetros'),
                    const Tab(text: 'Horarios'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _RulesTab(provider: provider, isHitl: isHitl),
                    if (isHitl) _ThresholdsTab(provider: provider),
                    _SchedulesTab(provider: provider),
                  ],
                ),
              ),
            ],
          ),
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
      case OperationMode.humanInTheLoop: return 'HITL';
    }
  }

  String get _modeDesc {
    switch (mode) {
      case OperationMode.manual:
        return 'Tú controlas cada acción del corral de forma directa.';
      case OperationMode.automatic:
        return 'El sistema aplica la configuración automática.';
      case OperationMode.humanInTheLoop:
        return 'El sistema solicita tu aprobación antes de ejecutar acciones críticas.';
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
          const SizedBox(height: 12),
          Row(
            children: [
              _ModeBtn(label: 'Manual', icon: Icons.pan_tool_outlined, mode: OperationMode.manual, current: mode, onTap: onChanged),
              const SizedBox(width: 6),
              _ModeBtn(label: 'Automático', icon: Icons.auto_fix_high_outlined, mode: OperationMode.automatic, current: mode, onTap: onChanged),
              const SizedBox(width: 6),
              _ModeBtn(label: 'HITL', icon: Icons.supervised_user_circle_outlined, mode: OperationMode.humanInTheLoop, current: mode, onTap: onChanged),
            ],
          ),
          const SizedBox(height: 12),
          Text(_modeDesc, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
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
  final bool isHitl;
  const _RulesTab({required this.provider, required this.isHitl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _InfoNote(
          icon: Icons.info_outline_rounded,
          text: 'Las reglas se evalúan continuamente. En modo HITL las acciones críticas requieren tu aprobación.',
          color: AppColors.primary,
        ),
        const SizedBox(height: 14),

        const _SectionLabel('REGLAS CONFIGURADAS'),
        const SizedBox(height: 10),

        ...provider.rules.map((rule) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RuleCard(rule: rule, provider: provider, isHitl: isHitl),
        )),

        const SizedBox(height: 14),

        if (isHitl)
          GestureDetector(
            onTap: () => _showRuleDialog(context),
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
                  Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Crear nueva regla', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showRuleDialog(BuildContext context, {AutomationRule? editRule}) {
    showDialog(
      context: context,
      builder: (_) => _AddEditRuleDialog(provider: provider, editRule: editRule),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final AutomationRule rule;
  final FarmProvider provider;
  final bool isHitl;
  const _RuleCard({required this.rule, required this.provider, required this.isHitl});

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SI Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rule.conditionLabel.toLowerCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // ENTONCES Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '➔ ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'ENTONCES ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.foreground,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rule.actionLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: rule.enabled,
                  activeColor: AppColors.primary,
                  onChanged: (_) => provider.toggleRule(rule.id),
                ),
              ],
            ),
          ),

          // Footer Actions (Only shown in HITL mode)
          if (isHitl)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.muted.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => _AddEditRuleDialog(provider: provider, editRule: rule),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.edit_outlined, size: 12, color: AppColors.info),
                        SizedBox(width: 4),
                        Text('Editar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.info)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      final duplicate = AutomationRule(
                        id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
                        condition: rule.condition,
                        conditionLabel: '${rule.conditionLabel} (Copia)',
                        action: rule.action,
                        actionLabel: rule.actionLabel,
                        enabled: rule.enabled,
                        requiresHITL: rule.requiresHITL,
                      );
                      provider.addRule(duplicate);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Regla duplicada con éxito'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.copy_rounded, size: 12, color: AppColors.mutedForeground),
                        SizedBox(width: 4),
                        Text('Duplicar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      provider.deleteRule(rule.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Regla eliminada'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.delete_outline_rounded, size: 12, color: AppColors.destructive),
                        SizedBox(width: 4),
                        Text('Eliminar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.destructive)),
                      ],
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

// ── Add/Edit Rule Dialog ──────────────────────────────────────────────────────

class _AddEditRuleDialog extends StatefulWidget {
  final FarmProvider provider;
  final AutomationRule? editRule;
  const _AddEditRuleDialog({required this.provider, this.editRule});

  @override
  State<_AddEditRuleDialog> createState() => _AddEditRuleDialogState();
}

class _AddEditRuleDialogState extends State<_AddEditRuleDialog> {
  late String _condition;
  late String _action;
  late bool _requiresHITL;
  late double _selectedWaterThreshold;

  static const _conditions = [
    ('motion_detected', 'Movimiento detectado (PIR)'),
    ('door_open', 'Puerta abierta'),
  ];

  static const _actions = [
    ('send_notification', 'Notificar al operador'),
    ('request_door', 'Solicitar apertura de puerta'),
    ('trigger_alarm', 'Activar LED de alarma'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editRule != null) {
      final r = widget.editRule!;
      _requiresHITL = r.requiresHITL;
      _action = r.action;
      _condition = r.condition;
    } else {
      _condition = 'motion_detected';
      _action = 'send_notification';
      _requiresHITL = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.editRule == null ? 'Crear Regla' : 'Editar Regla';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.card,
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SI ocurre la condición:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _condition,
                  items: _conditions.map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => _condition = v!),
                  isExpanded: true,
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text('ENTONCES ejecutar acción:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _action,
                  items: _actions.map((a) => DropdownMenuItem(value: a.$1, child: Text(a.$2, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => _action = v!),
                  isExpanded: true,
                ),
              ),
            ),

            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Requiere aprobación del operador (HITL)', style: TextStyle(fontSize: 12)),
              value: _requiresHITL,
              activeColor: AppColors.primary,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _requiresHITL = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final condLabel = _conditions.firstWhere((c) => c.$1 == _condition).$2;
            final actLabel = _actions.firstWhere((a) => a.$1 == _action).$2;

            if (widget.editRule != null) {
              final updated = AutomationRule(
                id: widget.editRule!.id,
                condition: _condition,
                conditionLabel: condLabel,
                action: _action,
                actionLabel: actLabel,
                enabled: widget.editRule!.enabled,
                requiresHITL: _requiresHITL,
              );
              widget.provider.updateRule(updated);
            } else {
              final newRule = AutomationRule(
                id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
                condition: _condition,
                conditionLabel: condLabel,
                action: _action,
                actionLabel: actLabel,
                enabled: true,
                requiresHITL: _requiresHITL,
              );
              widget.provider.addRule(newRule);
            }
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// ── Thresholds Tab ─────────────────────────────────────────────────────────

class _ThresholdsTab extends StatelessWidget {
  final FarmProvider provider;
  const _ThresholdsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.settings_backup_restore_rounded, size: 16),
          title: const Text('Restablecer valores recomendados'),
          onTap: () {
            provider.resetDoorParams();
          },
        ),
        const SizedBox(height: 16),
        const _SectionLabel('PARÁMETROS DE PUERTA AUTOMÁTICA'),
        const SizedBox(height: 10),
        _ParamsGroup(provider: provider),
      ],
    );
  }
}

class _ThresholdSliderCard extends StatelessWidget {
  final String label;
  final double value;
  final double recommended;
  final void Function(double) onChanged;

  const _ThresholdSliderCard({required this.label, required this.value, required this.recommended, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Recomendado: ${recommended.toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                ],
              ),
              Container(
                width: 60,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text('${value.toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: value,
            min: 0.0,
            max: 100.0,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ParamsGroup extends StatelessWidget {
  final FarmProvider provider;
  const _ParamsGroup({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ParamRow(
            label: 'Tiempo apertura (seg)',
            value: provider.doorOpenTimeSeconds,
            onChanged: (v) => provider.updateDoorParams(openTime: v),
          ),
          const Divider(height: 24),
          _ParamRow(
            label: 'Tiempo máx abierta (min)',
            value: provider.doorMaxOpenMinutes,
            onChanged: (v) => provider.updateDoorParams(maxOpen: v),
          ),
        ],
      ),
    );
  }
}

class _ParamRow extends StatelessWidget {
  final String label;
  final int value;
  final void Function(int) onChanged;

  const _ParamRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.foreground))),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.mutedForeground),
          onPressed: () => onChanged((value - 1).clamp(1, 999)),
        ),
        Container(
          width: 50,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text('$value', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.primary),
          onPressed: () => onChanged(value + 1),
        ),
      ],
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
      default: return schedule.action;
    }
  }

  IconData get _actionIcon {
    switch (schedule.action) {
      case 'open_door': return Icons.lock_open_rounded;
      case 'close_door': return Icons.lock_rounded;
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
