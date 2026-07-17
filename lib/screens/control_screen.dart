import 'dart:async';
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

              // Mode info banner
              _ModeBanner(mode: s.operationMode),
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

// ── Mode Banner ───────────────────────────────────────────────────────────────

class _ModeBanner extends StatelessWidget {
  final OperationMode mode;
  const _ModeBanner({required this.mode});

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case OperationMode.manual:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.pan_tool_outlined, size: 15, color: AppColors.info),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Modo Manual — Controlas directamente cada dispositivo.',
                  style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      case OperationMode.automatic:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.auto_fix_high_outlined, size: 15, color: AppColors.success),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Modo Automático — El sistema gestiona los dispositivos según los umbrales configurados.',
                  style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      case OperationMode.humanInTheLoop:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.supervised_user_circle_outlined, size: 15, color: AppColors.warning),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Modo HITL — El sistema sugiere acciones pero tú apruebas o rechazas cada una. Configura umbrales aquí.',
                  style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
    }
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

// ── HITL Threshold Editor ─────────────────────────────────────────────────────


class _ThresholdSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _ThresholdSlider({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${value.toStringAsFixed(0)}$unit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: iconColor)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: iconColor,
            thumbColor: iconColor,
            overlayColor: iconColor.withOpacity(0.15),
            inactiveTrackColor: AppColors.border,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) / 5).round(),
            onChanged: onChanged,
          ),
        ),
      ],
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

    final metrics = [
      _MetricRow(icon: Icons.door_sliding_outlined, label: 'Aperturas hoy', value: '${state.doorOpenCount}'),
      _MetricRow(icon: Icons.timer_outlined, label: 'Tiempo abierta', value: '${openMins}min'),
      _MetricRow(icon: Icons.access_time_rounded, label: 'Última apertura', value: lastOpenedStr),
      _MetricRow(icon: Icons.person_outline_rounded, label: 'Operado por', value: state.doorLastUser),
    ];

    final isMoving = state.doorState == DoorState.moving;
    final isOpen = state.doorState == DoorState.open;
    final isClosed = state.doorState == DoorState.closed;

    Widget actions;
    switch (state.operationMode) {
      case OperationMode.manual:
        actions = Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (!isMoving && !isOpen)
                    ? () => provider.openDoor(user: 'Operador', origin: 'Manual')
                    : null,
                icon: const Icon(Icons.lock_open_rounded, size: 14),
                label: const Text('Abrir'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (!isMoving && !isClosed)
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
              child: Center(
                child: isMoving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info),
                      )
                    : const Icon(Icons.stop_circle_outlined, size: 16, color: AppColors.mutedForeground),
              ),
            ),
          ],
        );
        break;
      case OperationMode.automatic:
        actions = _AutoInfoRow(
          icon: Icons.auto_fix_high_outlined,
          text: 'La puerta se opera automáticamente según el calendario y las reglas configuradas.',
        );
        break;
      case OperationMode.humanInTheLoop:
        actions = _HitlActionRow(
          label: 'Revisar y decidir',
          icon: Icons.supervised_user_circle_outlined,
          onTap: () => _showDoorHitlSheet(context),
        );
        break;
    }

    final stateLabel = switch (state.doorState) {
      DoorState.open => 'Abierta',
      DoorState.closed => 'Cerrada',
      DoorState.moving => state.doorTarget == DoorState.open ? 'Abriendo…' : 'Cerrando…',
    };
    final stateTone = switch (state.doorState) {
      DoorState.open => _Tone.success,
      DoorState.closed => _Tone.neutral,
      DoorState.moving => _Tone.info,
    };

    return _ControlCard(
      icon: state.doorState == DoorState.open
          ? Icons.door_back_door_outlined
          : Icons.door_front_door_outlined,
      title: 'Puerta automática',
      subtitle: 'Portón principal del corral',
      stateLabel: stateLabel,
      stateTone: stateTone,
      statePulsing: isMoving,
      animation: DoorAnimation(doorState: state.doorState, doorTarget: state.doorTarget),
      metrics: metrics,
      actions: actions,
    );
  }

  void _showDoorHitlSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DoorHitlSheet(state: state, provider: provider),
    );
  }
}

class _DoorHitlSheet extends StatelessWidget {
  final FarmState state;
  final FarmProvider provider;
  const _DoorHitlSheet({required this.state, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.supervised_user_circle_outlined, color: AppColors.warning),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Puerta — Decisión HITL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Estado actual: ${state.doorState == DoorState.open ? "Abierta" : "Cerrada"}',
            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          _HitlSheetAction(
            icon: Icons.lock_open_rounded,
            label: 'Aprobar apertura de puerta',
            color: AppColors.success,
            onTap: state.doorState == DoorState.closed ? () {
              provider.openDoor(user: 'HITL Operador', origin: 'HITL');
              Navigator.pop(context);
            } : null,
          ),
          const SizedBox(height: 10),
          _HitlSheetAction(
            icon: Icons.lock_rounded,
            label: 'Aprobar cierre de puerta',
            color: AppColors.info,
            onTap: state.doorState == DoorState.open ? () {
              provider.closeDoor(user: 'HITL Operador', origin: 'HITL');
              Navigator.pop(context);
            } : null,
          ),
          const SizedBox(height: 10),
          _HitlSheetAction(
            icon: Icons.do_not_disturb_rounded,
            label: 'Ignorar acción pendiente',
            color: AppColors.mutedForeground,
            onTap: () => Navigator.pop(context),
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

          // Actions depending on mode
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _buildPirActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPirActions(BuildContext context) {
    switch (state.operationMode) {
      case OperationMode.manual:
        if (!state.animalDetected) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.mutedForeground),
                SizedBox(width: 8),
                Text('Sin movimiento · Zona segura',
                    style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              ],
            ),
          );
        }
        return Column(
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
                    label: 'Verificar puerta',
                    icon: Icons.door_front_door_outlined,
                    onTap: () {
                      // Desplazarse o enfocar visualmente el módulo de la puerta
                      // Como estamos en la misma pantalla de control, realizamos un scroll al inicio o mostramos un SnackBar indicando que verifique el estado arriba
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🚪 Estado de la puerta: ${provider.state.doorState == DoorState.open ? "Abierta" : "Cerrada"}. Controla la puerta en la sección superior.'),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    color: AppColors.primary,
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
        );

      case OperationMode.automatic:
        return _AutoInfoRow(
          icon: Icons.sensors_rounded,
          text: 'El sistema envía notificaciones automáticamente al detectar movimiento.',
        );

      case OperationMode.humanInTheLoop:
        return _HitlActionRow(
          label: 'Revisar y decidir',
          icon: Icons.supervised_user_circle_outlined,
          onTap: () => _showPirHitlSheet(context),
        );
    }
  }

  void _showPirHitlSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PirHitlSheet(state: state, provider: provider),
    );
  }
}

class _PirHitlSheet extends StatelessWidget {
  final FarmState state;
  final FarmProvider provider;
  const _PirHitlSheet({required this.state, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sensors_rounded, color: AppColors.warning),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Sensor PIR — Decisión HITL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            state.animalDetected
                ? '⚠️ Movimiento actualmente detectado en Zona Norte'
                : '✅ Sin movimiento detectado — Zona segura',
            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          if (state.animalDetected) ...[
            _HitlSheetAction(
              icon: Icons.lock_open_rounded,
              label: 'Aprobar apertura de puerta',
              color: AppColors.success,
              onTap: () {
                provider.openDoor(user: 'HITL Operador', origin: 'HITL');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _HitlSheetAction(
              icon: Icons.notifications_active_rounded,
              label: 'Activar alarma',
              color: AppColors.warning,
              onTap: () {
                provider.triggerAlarm();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _HitlSheetAction(
              icon: Icons.report_outlined,
              label: 'Registrar incidente',
              color: AppColors.destructive,
              onTap: () {
                provider.registerIncident('Incidente HITL — Zona norte');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
          _HitlSheetAction(
            icon: Icons.do_not_disturb_rounded,
            label: 'Ignorar evento',
            color: AppColors.mutedForeground,
            onTap: () {
              if (state.animalDetected) {
                provider.registerIncident('Evento PIR ignorado por HITL operador');
              }
              Navigator.pop(context);
            },
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

class _WaterModule extends StatefulWidget {
  final FarmState state;
  final FarmProvider provider;
  const _WaterModule({required this.state, required this.provider});

  @override
  State<_WaterModule> createState() => _WaterModuleState();
}

class _WaterModuleState extends State<_WaterModule> {
  bool _localAnimating = false;
  Timer? _animationTimer;

  void _triggerFillingAnimation() {
    _animationTimer?.cancel();
    setState(() {
      _localAnimating = true;
    });
    _animationTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _localAnimating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastFilledStr = widget.state.waterLastFilledAt != null
        ? DateFormat('HH:mm dd/MM').format(widget.state.waterLastFilledAt!)
        : 'Nunca';

    Widget actions;
    switch (widget.state.operationMode) {
      case OperationMode.manual:
        actions = Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (widget.state.waterState != WaterState.full && !_localAnimating)
                    ? () {
                        widget.provider.fillWater(user: 'Operador', origin: 'Manual');
                        _triggerFillingAnimation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('💧 Proceso de llenado iniciado'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.water_drop_rounded, size: 14),
                label: const Text('Llenar bebedero'),
              ),
            ),
          ],
        );
        break;
      case OperationMode.automatic:
        actions = const _AutoThresholdInfo();
        break;
      case OperationMode.humanInTheLoop:
        actions = _HitlActionRow(
          label: 'Revisar y decidir (Human in the Loop)',
          icon: Icons.supervised_user_circle_outlined,
          onTap: () => _showWaterHitlSheet(context),
        );
        break;
    }

    return _ControlCard(
      icon: Icons.water_drop_outlined,
      title: 'Bebedero',
      subtitle: 'Sensor de flotador',
      stateLabel: widget.state.waterState == WaterState.full ? 'Estado: LLENO' : 'Estado: SIN AGUA',
      stateTone: widget.state.waterState == WaterState.full ? _Tone.success : _Tone.alert,
      animation: WaterAnimation(
        waterState: _localAnimating ? WaterState.filling : widget.state.waterState,
        waterPercent: _localAnimating
            ? 100.0
            : (widget.state.waterState == WaterState.full ? 100.0 : 10.0),
      ),
      metrics: [
        _MetricRow(
          icon: Icons.sensors_rounded,
          label: 'Sensor flotador',
          value: widget.state.waterState == WaterState.full ? '🟢 LLENO' : '🔴 SIN AGUA',
          valueColor: widget.state.waterState == WaterState.full ? AppColors.success : AppColors.destructive,
        ),
        _MetricRow(
          icon: Icons.electrical_services_rounded,
          label: 'Bomba de agua',
          value: _localAnimating ? 'Activa (Llenando...)' : 'Apagada',
          valueColor: _localAnimating ? AppColors.info : AppColors.foreground,
        ),
        _MetricRow(icon: Icons.access_time_rounded, label: 'Último llenado', value: lastFilledStr),
      ],
      actions: actions,
    );
  }

  void _showWaterHitlSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WaterHitlSheet(
        state: widget.state,
        provider: widget.provider,
        isFilling: _localAnimating,
        onApprove: () {
          widget.provider.fillWater(user: 'HITL Operador', origin: 'HITL');
          _triggerFillingAnimation();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💧 Proceso de llenado iniciado'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

class _WaterHitlSheet extends StatelessWidget {
  final FarmState state;
  final FarmProvider provider;
  final bool isFilling;
  final VoidCallback onApprove;
  const _WaterHitlSheet({
    required this.state,
    required this.provider,
    required this.isFilling,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: AppColors.warning),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Bebedero — Decisión HITL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Flotador: ${state.waterState == WaterState.full ? "🟢 LLENO" : "🔴 SIN AGUA"} · Bomba: ${isFilling ? "Activa" : "Apagada"}',
            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          _HitlSheetAction(
            icon: Icons.water_drop_rounded,
            label: 'Aprobar llenado del bebedero',
            color: AppColors.info,
            onTap: (state.waterState == WaterState.empty && !isFilling) ? () {
              onApprove();
              Navigator.pop(context);
            } : null,
          ),
          const SizedBox(height: 10),
          _HitlSheetAction(
            icon: Icons.do_not_disturb_rounded,
            label: 'Posponer decisión',
            color: AppColors.mutedForeground,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ── Auto threshold info (Automático mode) ────────────────────────────────────

class _AutoThresholdInfo extends StatelessWidget {
  const _AutoThresholdInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_fix_high_outlined, size: 14, color: AppColors.success),
              SizedBox(width: 6),
              Text('Configuración automática activa',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 8),
          const _AutoThresholdRow(
            icon: Icons.sensors_rounded,
            iconColor: AppColors.success,
            label: 'Boya / Flotador',
            value: 'Control físico de nivel',
          ),
          const SizedBox(height: 4),
          const _AutoThresholdRow(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.info,
            label: 'Bomba',
            value: 'Alimentación continua USB',
          ),
        ],
      ),
    );
  }
}


class _AutoThresholdRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _AutoThresholdRow({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.foreground)),
      ],
    );
  }
}

// ── Shared HITL action row ───────────────────────────────────────────────────

class _HitlActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _HitlActionRow({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.warning),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

// ── Shared Auto info row ──────────────────────────────────────────────────────

class _AutoInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AutoInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ── HITL Bottom Sheet Action ──────────────────────────────────────────────────

class _HitlSheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _HitlSheetAction({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.08) : AppColors.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: enabled ? color.withOpacity(0.3) : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: enabled ? color : AppColors.mutedForeground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled ? color : AppColors.mutedForeground,
                  )),
            ),
            if (!enabled)
              const Text('No disponible',
                  style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
          ],
        ),
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
  final bool statePulsing;
  final Widget animation;
  final List<Widget> metrics;
  final Widget actions;

  const _ControlCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stateLabel,
    required this.stateTone,
    this.statePulsing = false,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statePulsing) ...[
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.6, color: _toneColor),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(stateLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _toneColor)),
                    ],
                  ),
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
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