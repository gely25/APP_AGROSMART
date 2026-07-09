import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/farm_provider.dart';
import '../../models/farm_state.dart';
import '../../widgets/alarm_card.dart';
import '../../animations/door_animation.dart';
import '../../animations/feeder_animation.dart';
import '../../animations/water_animation.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final s = provider.state;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alarm card (always visible at top)
              AlarmCard(
                alarmActive: s.alarmActive,
                onSilence: provider.silenceAlarm,
              ),

              const SizedBox(height: 16),

              // Door module
              _ControlModule(
                icon: s.doorState == DoorState.open
                    ? Icons.door_back_door_outlined
                    : Icons.door_front_door_outlined,
                title: 'Puerta automática',
                subtitle: 'Portón principal del corral',
                stateLabel: s.doorState == DoorState.open ? 'Abierta' : 'Cerrada',
                stateTone: s.doorState == DoorState.open ? _Tone.success : _Tone.alert,
                animation: DoorAnimation(doorState: s.doorState),
                buttons: [
                  _ActionButton(
                    label: 'Abrir puerta',
                    primary: true,
                    onPressed: s.doorState == DoorState.closed ? provider.openDoor : null,
                  ),
                  _ActionButton(
                    label: 'Cerrar puerta',
                    primary: false,
                    onPressed: s.doorState == DoorState.open ? provider.closeDoor : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Feeder module
              _ControlModule(
                icon: Icons.set_meal_outlined,
                title: 'Comedero inteligente',
                subtitle: 'Tapa automatizada de alimento',
                stateLabel: s.feederState == FeederState.open ? 'Abierto' : 'Cerrado',
                stateTone: s.feederState == FeederState.open ? _Tone.success : _Tone.alert,
                animation: FeederAnimation(feederState: s.feederState),
                buttons: [
                  _ActionButton(
                    label: 'Abrir comedero',
                    primary: true,
                    onPressed: s.feederState == FeederState.closed ? provider.openFeeder : null,
                  ),
                  _ActionButton(
                    label: 'Cerrar comedero',
                    primary: false,
                    onPressed: s.feederState == FeederState.open ? provider.closeFeeder : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Water module
              _ControlModule(
                icon: Icons.water_drop_outlined,
                title: 'Bebedero inteligente',
                subtitle: 'Nivel de agua del ganado',
                stateLabel: s.waterState == WaterState.full
                    ? 'Lleno'
                    : s.waterState == WaterState.filling
                        ? 'Llenándose…'
                        : 'Vacío',
                stateTone: s.waterState == WaterState.full
                    ? _Tone.success
                    : s.waterState == WaterState.filling
                        ? _Tone.info
                        : _Tone.alert,
                animation: WaterAnimation(waterState: s.waterState),
                buttons: [
                  _ActionButton(
                    label: 'Llenar bebedero',
                    primary: true,
                    onPressed: s.waterState == WaterState.empty ? provider.fillWater : null,
                  ),
                  _ActionButton(
                    label: 'Vaciar bebedero',
                    primary: false,
                    onPressed: s.waterState != WaterState.empty ? provider.emptyWater : null,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

enum _Tone { success, alert, info }

class _ControlModule extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String stateLabel;
  final _Tone stateTone;
  final Widget animation;
  final List<Widget> buttons;

  const _ControlModule({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stateLabel,
    required this.stateTone,
    required this.animation,
    required this.buttons,
  });

  Color get _toneColor {
    switch (stateTone) {
      case _Tone.success: return AppColors.success;
      case _Tone.alert:   return AppColors.destructive;
      case _Tone.info:    return AppColors.info;
    }
  }

  Color get _toneBg {
    switch (stateTone) {
      case _Tone.success: return AppColors.successLight;
      case _Tone.alert:   return AppColors.destructiveLight;
      case _Tone.info:    return AppColors.infoLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
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
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.foreground, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                        style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        )),
                      Text(subtitle,
                        style: const TextStyle(
                          fontSize: 12, color: AppColors.mutedForeground,
                        )),
                    ],
                  ),
                ),
                // State pill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _toneBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    stateLabel,
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _toneColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animation stage
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: animation,
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: buttons.map((b) {
                final idx = buttons.indexOf(b);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: idx == 0 ? 0 : 8),
                    child: b,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.primary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(label, textAlign: TextAlign.center),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
