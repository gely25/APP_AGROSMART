import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';
import '../widgets/status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              // Hero illustration
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 160,
                      child: Image.asset(
                        'assets/images/corral_illustration.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.primary.withOpacity(0.70),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Text overlay
                    Positioned(
                      bottom: 16, left: 16, right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado general',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.80),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.alarmActive
                                ? 'Atención requerida en el corral'
                                : 'Todo funciona con normalidad',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Status grid 2×3
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  StatusCard(
                    icon: s.connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    title: 'Conexión ESP32',
                    value: s.connected ? 'Conectado' : 'Sin conexión',
                    tone: s.connected ? StatusTone.success : StatusTone.alert,
                  ),
                  StatusCard(
                    icon: s.doorState == DoorState.open
                        ? Icons.door_back_door_outlined
                        : Icons.door_front_door_outlined,
                    title: 'Puerta',
                    value: s.doorState == DoorState.open ? 'Abierta' : 'Cerrada',
                    tone: s.doorState == DoorState.open ? StatusTone.success : StatusTone.alert,
                  ),
                  StatusCard(
                    icon: Icons.set_meal_outlined,
                    title: 'Comedero',
                    value: s.feederState == FeederState.open ? 'Abierto' : 'Cerrado',
                    tone: s.feederState == FeederState.open ? StatusTone.success : StatusTone.alert,
                  ),
                  StatusCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Bebedero',
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
                  StatusCard(
                    icon: Icons.pets_outlined,
                    title: 'Animal detectado',
                    value: s.animalDetected ? 'Presente' : 'Ausente',
                    tone: s.animalDetected ? StatusTone.info : StatusTone.neutral,
                    pulse: s.animalDetected,
                  ),
                  StatusCard(
                    icon: s.alarmActive
                        ? Icons.notifications_active_outlined
                        : Icons.shield_outlined,
                    title: 'Alarma',
                    value: s.alarmActive ? 'Activada' : 'Sin alertas',
                    tone: s.alarmActive ? StatusTone.alert : StatusTone.success,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Last update row
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
                    const Text(
                      'Última actualización',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                    ),
                    const Spacer(),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
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
