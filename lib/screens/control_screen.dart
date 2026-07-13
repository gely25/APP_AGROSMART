import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';
import '../widgets/alarm_card.dart';
import '../animations/door_animation.dart';
import '../animations/pir_sensor_animation.dart';
import '../animations/water_animation.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final s = provider.state;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode selector bar
              _ModeSelector(mode: s.operationMode, onChanged: provider.setMode),
              const SizedBox(height: 12),

              // Alarm card
              AlarmCard(alarmActive: s.alarmActive, onSilence: provider.silenceAlarm),
              const SizedBox(height: 14),

              // HITL pending water approval
              if (s.hitlPendingWater) ...[
                _HitlApprovalBanner(
                  onApprove: () => provider.approveWaterFill(),
                  onReject: () => provider.rejectWaterFill(),
                ),
                const SizedBox(height: 14),
              ],

              // Door Module
              _DoorModule(state: s, provider: provider),
              const SizedBox(height: 14),

              // PIR Module
              _PirModule(state: s, provider: provider),
              const SizedBox(height: 14),

              // Water Module
              _WaterModule(state: s, provider: provider),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ── Mode Selector ────────────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  final OperationMode mode;
  final void Function(OperationMode) onChanged;
  const _ModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const modes = [
      (OperationMode.manual, 'Manual', Icons.pan_tool_outlined),
      (OperationMode.automatic, 'Automático', Icons.auto_fix_high_outlined),
      (OperationMode.humanInTheLoop, 'HITL', Icons.supervised_user_circle_outlined),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: modes.map((m) {
          final active = mode == m.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(m.$3, size: 16, color: active ? Colors.white : AppColors.mutedForeground),
                    const SizedBox(height: 3),
                    Text(m.$2, style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active ? Colors.white : AppColors.mutedForeground,
                    )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── HITL Approval Banner ─────────────────────────────────────────────────────

class _HitlApprovalBanner extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _HitlApprovalBanner({required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pending_actions_rounded, size: 16, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Aprobación requerida (HITL)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('El nivel de agua está bajo el 20%. Se requiere su confirmación para iniciar el llenado automático.',
              style: TextStyle(fontSize: 11, color: AppColors.foreground)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: const Text('Aprobar llenado'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded, size: 14),
                  label: const Text('Ignorar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Door Module ──────────────────────────────────────────────────────────────

class _DoorModule extends StatelessWidget {
  final FarmState state;
  final FarmProvider provider;
  const _DoorModule({required this.state, required this.provider});

  @override
  Widget build(BuildContext context) {
    final lastOpenedStr = state.doorLastOpenedAt != null
        ? DateFormat('HH:mm dd/MM').format(state.doorLastOpenedAt!)
        : 'Nunca';
    final openMins = state.doorOpenSeconds ~/ 60;

    return _ControlCard(
      icon: state.doorState == DoorState.open
          ? Icons.door_back_door_outlined
          : Icons.door_front_door_outlined,
      title: 'Puerta automática',
      subtitle: 'Portón principal del corral',
      stateLabel: state.doorState == DoorState.open ? 'Abierta' : 'Cerrada',
      stateTone: state.doorState == DoorState.open ? _Tone.success : _Tone.neutral,
      animation: DoorAnimation(doorState: state.doorState),
      metrics: [
        _MetricRow(icon: Icons.door_sliding_outlined, label: 'Aperturas hoy', value: '${state.doorOpenCount}'),
        _MetricRow(icon: Icons.timer_outlined, label: 'Tiempo abierta', value: '${openMins}min'),
        _MetricRow(icon: Icons.access_time_rounded, label: 'Última apertura', value: lastOpenedStr),
        _MetricRow(icon: Icons.person_outline_rounded, label: 'Operado por', value: state.doorLastUser),
      ],
      actions: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: state.doorState == DoorState.closed
                  ? () => provider.openDoor(user: 'Operador', origin: 'Manual')
                  : null,
              icon: const Icon(Icons.lock_open_rounded, size: 14),
              label: const Text('Abrir'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.doorState == DoorState.open
                  ? () => provider.closeDoor(user: 'Operador', origin: 'Manual')
                  : null,
              icon: const Icon(Icons.lock_rounded, size: 14),
              label: const Text('Cerrar'),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(Icons.stop_circle_outlined, size: 16, color: AppColors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PIR Module ───────────────────────────────────────────────────────────────

class _PirModule extends StatelessWidget {
  final FarmState state;
  final FarmProvider provider;
  const _PirModule({required this.state, required this.provider});

  @override
  Widget build(BuildContext context) {
    final lastMotionStr = DateFormat('HH:mm:ss').format(state.lastMotionTime);
    final elapsed = DateTime.now().difference(state.lastMotionTime);
    final elapsedStr = elapsed.inMinutes > 60
        ? '${elapsed.inHours}h ${elapsed.inMinutes.remainder(60)}m'
        : '${elapsed.inMinutes}m ${elapsed.inSeconds.remainder(60)}s';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: state.animalDetected ? AppColors.destructiveBg : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.animalDetected
              ? AppColors.destructive.withOpacity(0.5)
              : AppColors.border,
          width: state.animalDetected ? 2 : 1,
        ),
        boxShadow: state.animalDetected
            ? [BoxShadow(color: AppColors.destructive.withOpacity(0.15), blurRadius: 16, spreadRadius: 2)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: state.animalDetected ? AppColors.destructive.withOpacity(0.15) : AppColors.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.sensors_rounded,
                      color: state.animalDetected ? AppColors.destructive : AppColors.foreground, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sensor PIR de presencia',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Zona norte — Acceso principal',
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                _PirStatusPill(detected: state.animalDetected),
              ],
            ),
          ),

          // Alert banner
          if (state.animalDetected) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.destructive,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¡Movimiento detectado! · $lastMotionStr · Zona Norte',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PirSensorAnimation(motionDetected: state.animalDetected),
          ),

          // Metrics
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _MetricRow(icon: Icons.history_toggle_off_rounded, label: 'Última detección', value: lastMotionStr),
                const SizedBox(height: 6),
                _MetricRow(icon: Icons.timelapse_rounded, label: 'Tiempo transcurrido', value: elapsedStr),
                const SizedBox(height: 6),
                _MetricRow(icon: Icons.location_on_outlined, label: 'Zona', value: 'Norte — Acceso principal'),
                const SizedBox(height: 6),
                _MetricRow(icon: Icons.bolt_rounded, label: 'Eventos hoy', value: '${state.pirEventsToday}'),
              ],
            ),
          ),

          // Actions
          if (state.animalDetected)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SmallAction(
                          label: 'Ignorar',
                          icon: Icons.do_not_disturb_rounded,
                          onTap: () => provider.registerIncident('Evento PIR ignorado por operador'),
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SmallAction(
                          label: 'Abrir puerta',
                          icon: Icons.lock_open_rounded,
                          onTap: () => provider.openDoor(user: 'Operador (PIR)', origin: 'Manual'),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallAction(
                          label: 'Activar alarma',
                          icon: Icons.notifications_active_rounded,
                          onTap: provider.triggerAlarm,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SmallAction(
                          label: 'Reg. incidente',
                          icon: Icons.report_outlined,
                          onTap: () => provider.registerIncident('Incidente registrado por operador — Zona norte'),
                          color: AppColors.destructive,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Text('Sin movimiento · Zona segura',
                        style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PirStatusPill extends StatefulWidget {
  final bool detected;
  const _PirStatusPill({required this.detected});
  @override
  State<_PirStatusPill> createState() => _PirStatusPillState();
}

class _PirStatusPillState extends State<_PirStatusPill> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.detected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('Sin movimiento', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.destructive.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('⚡ MOVIMIENTO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

// ── Water Module ─────────────────────────────────────────────────────────────

class _WaterModule extends StatelessWidget {
  final FarmState state;
  final FarmProvider provider;
  const _WaterModule({required this.state, required this.provider});

  @override
  Widget build(BuildContext context) {
    final lastFilledStr = state.waterLastFilledAt != null
        ? DateFormat('HH:mm dd/MM').format(state.waterLastFilledAt!)
        : 'Nunca';
    final liters = state.waterLiters;
    final autonomy = state.waterAutonomyHours;

    return _ControlCard(
      icon: Icons.water_drop_outlined,
      title: 'Bebedero inteligente',
      subtitle: 'Sensor de nivel ultrasónico',
      stateLabel: state.waterLow
          ? '⚠️ Nivel bajo'
          : state.waterState == WaterState.full
              ? 'Lleno'
              : state.waterState == WaterState.filling
                  ? 'Llenándose…'
                  : 'Vacío',
      stateTone: state.waterLow
          ? _Tone.alert
          : state.waterState == WaterState.filling
              ? _Tone.info
              : _Tone.success,
      animation: WaterAnimation(waterState: state.waterState),
      metrics: [
        _MetricRow(icon: Icons.percent_rounded, label: 'Nivel', value: '${state.waterPercent.toStringAsFixed(0)}%'),
        _MetricRow(icon: Icons.water_rounded, label: 'Litros disponibles', value: '${liters.toStringAsFixed(1)} L'),
        _MetricRow(icon: Icons.local_drink_outlined, label: 'Capacidad total', value: '${state.waterCapacityL.toStringAsFixed(0)} L'),
        _MetricRow(icon: Icons.timelapse_rounded, label: 'Autonomía estimada', value: autonomy > 24 ? '>24h' : '${autonomy.toStringAsFixed(1)}h'),
        _MetricRow(icon: Icons.speed_rounded, label: 'Consumo diario', value: '${state.waterDailyConsumptionL.toStringAsFixed(1)} L/día'),
        _MetricRow(icon: Icons.access_time_rounded, label: 'Último llenado', value: lastFilledStr),
        _MetricRow(
          icon: Icons.settings_input_component_rounded,
          label: 'Válvula',
          value: state.valveOpen ? 'Abierta' : 'Cerrada',
          valueColor: state.valveOpen ? AppColors.success : AppColors.foreground,
        ),
      ],
      actions: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (state.waterState != WaterState.filling && state.waterPercent < 100)
                  ? () => provider.fillWater(user: 'Operador', origin: 'Manual')
                  : null,
              icon: const Icon(Icons.water_drop_rounded, size: 14),
              label: const Text('Llenar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.waterState != WaterState.empty ? provider.emptyWater : null,
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 14),
              label: const Text('Vaciar'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Generic Control Card ──────────────────────────────────────────────────────

class _ControlCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String stateLabel;
  final _Tone stateTone;
  final Widget animation;
  final List<Widget> metrics;
  final Widget actions;

  const _ControlCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stateLabel,
    required this.stateTone,
    required this.animation,
    required this.metrics,
    required this.actions,
  });

  Color get _toneColor {
    switch (stateTone) {
      case _Tone.success: return AppColors.success;
      case _Tone.alert:   return AppColors.destructive;
      case _Tone.info:    return AppColors.info;
      case _Tone.neutral: return AppColors.mutedForeground;
    }
  }

  Color get _toneBg {
    switch (stateTone) {
      case _Tone.success: return AppColors.successLight;
      case _Tone.alert:   return AppColors.destructiveLight;
      case _Tone.info:    return AppColors.infoLight;
      case _Tone.neutral: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppColors.foreground, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _toneBg, borderRadius: BorderRadius.circular(999)),
                  child: Text(stateLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _toneColor)),
                ),
              ],
            ),
          ),

          // Animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: animation,
          ),

          // Metrics
          if (metrics.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: metrics.indexed.map((e) => Padding(
                    padding: EdgeInsets.only(top: e.$1 > 0 ? 8 : 0),
                    child: e.$2,
                  )).toList(),
                ),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: actions,
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

enum _Tone { success, alert, info, neutral }

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.mutedForeground),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        const Spacer(),
        Text(value, style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: valueColor ?? AppColors.foreground,
        )),
      ],
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _SmallAction({required this.label, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Flexible(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
