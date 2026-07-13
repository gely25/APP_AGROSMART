import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';
import '../widgets/realtime_row.dart';
import '../widgets/status_card.dart';

class RealtimeScreen extends StatelessWidget {
  const RealtimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final s = provider.state;
        final timeStr = DateFormat('HH:mm:ss').format(s.lastUpdate);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sync info banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.info.withOpacity(0.25), width: 1),
                ),
                child: Row(
                  children: [
                    _PulseRadio(),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sincronización automática cada 5 segundos con el ESP32',
                        style: TextStyle(fontSize: 12, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data rows card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    RealtimeRow(
                      icon: s.connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                      label: 'Conexión WiFi',
                      value: s.connected ? 'Conectado' : 'Sin conexión',
                      tone: s.connected ? StatusTone.success : StatusTone.alert,
                    ),
                    const Divider(height: 1),
                    RealtimeRow(
                      icon: s.doorState == DoorState.open
                          ? Icons.door_back_door_outlined
                          : Icons.door_front_door_outlined,
                      label: 'Puerta',
                      value: s.doorState == DoorState.open ? 'Abierta' : 'Cerrada',
                      tone: s.doorState == DoorState.open ? StatusTone.success : StatusTone.alert,
                    ),
                    const Divider(height: 1),
                    RealtimeRow(
                      icon: Icons.sensors_rounded,
                      label: 'Sensor PIR',
                      value: s.animalDetected ? 'Movimiento detectado' : 'Sin movimiento',
                      tone: s.animalDetected ? StatusTone.info : StatusTone.neutral,
                    ),
                    const Divider(height: 1),
                    RealtimeRow(
                      icon: Icons.water_drop_outlined,
                      label: 'Bebedero',
                      value: s.waterState == WaterState.full
                          ? 'Lleno'
                          : s.waterState == WaterState.filling
                              ? 'Llenándose'
                              : 'Vacío',
                      tone: s.waterState == WaterState.empty
                          ? StatusTone.alert
                          : s.waterState == WaterState.filling
                              ? StatusTone.info
                              : StatusTone.success,
                    ),
                    const Divider(height: 1),
                    RealtimeRow(
                      icon: Icons.pets_outlined,
                      label: 'Animal detectado',
                      value: s.animalDetected ? 'Presente' : 'Ausente',
                      tone: s.animalDetected ? StatusTone.info : StatusTone.neutral,
                    ),
                    const Divider(height: 1),
                    RealtimeRow(
                      icon: s.alarmActive
                          ? Icons.notifications_active_outlined
                          : Icons.shield_outlined,
                      label: 'Alarma',
                      value: s.alarmActive ? 'Activada' : 'Sin alertas',
                      tone: s.alarmActive ? StatusTone.alert : StatusTone.success,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Last read row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 16, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    const Text('Última lectura',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    const Spacer(),
                    Text(timeStr,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        fontFamily: 'monospace', color: AppColors.foreground,
                      )),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Demo alarm trigger (only if no alarm)
              if (!s.alarmActive)
                GestureDetector(
                  onTap: provider.triggerAlarm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.destructive.withOpacity(0.40),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Simular alerta del ESP32 (demostración)',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: AppColors.destructive,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

/// Animated radio icon (pulsing)
class _PulseRadio extends StatefulWidget {
  @override
  State<_PulseRadio> createState() => _PulseRadioState();
}

class _PulseRadioState extends State<_PulseRadio>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: 0.5 + _ctrl.value * 0.5,
        child: const Icon(Icons.sensors_rounded, size: 20, color: AppColors.info),
      ),
    );
  }
}
