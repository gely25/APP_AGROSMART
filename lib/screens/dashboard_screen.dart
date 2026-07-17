import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, provider, __) {
        final s = provider.state;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Warning Banner ─────────────────────────────────────────────
              if (s.alarmActive) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2), // Light red bg
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.destructive,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Atención requerida',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Alarma activa — revisa el control del corral',
                              style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          // Navigate to Control tab or handle click
                        },
                        child: const Text('Ver', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 10),

              // ── DISPOSITIVOS ───────────────────────────────────────────────
              const _SectionLabel('DISPOSITIVOS'),
              const SizedBox(height: 10),

              // Puerta automática Row
              _DeviceRow(
                icon: Icons.door_front_door_outlined,
                title: 'Puerta automática',
                subtitle: 'Controlada por servomotor',
                statusText: s.doorState == DoorState.open ? 'Abierta' : 'Cerrada',
                statusColor: s.doorState == DoorState.open ? const Color(0xFF10B981) : AppColors.mutedForeground,
                statusBgColor: s.doorState == DoorState.open ? const Color(0xFFE6F4EA) : const Color(0xFFF1F3F4),
              ),
              const SizedBox(height: 10),

              // Bebedero inteligente Row
              _DeviceRow(
                icon: Icons.opacity_rounded,
                title: 'Bebedero inteligente',
                subtitle: 'Boya física (Lleno / Sin agua)',
                statusText: s.waterState == WaterState.full ? 'Lleno' : 'Sin Agua',
                statusColor: s.waterState == WaterState.full ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                statusBgColor: s.waterState == WaterState.full ? const Color(0xFFE6F4EA) : const Color(0xFFFFF7EA),
              ),
              const SizedBox(height: 10),

              // Sensor PIR de presencia Row
              _DeviceRow(
                icon: Icons.track_changes_rounded,
                title: 'Sensor PIR de presencia',
                subtitle: 'Detección por sensor físico PIR',
                statusText: s.animalDetected ? 'Movimiento' : 'Tranquilo',
                statusColor: s.animalDetected ? const Color(0xFFF59E0B) : AppColors.mutedForeground,
                statusBgColor: s.animalDetected ? const Color(0xFFFFF7EA) : const Color(0xFFF1F3F4),
              ),
              const SizedBox(height: 20),

              // ── CONTROLADOR ────────────────────────────────────────────────
              const _SectionLabel('CONTROLADOR'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _ControladorStatBox(
                      value: '${s.wifiRssi}',
                      suffix: ' dBm',
                      dotColor: const Color(0xFFF59E0B),
                      label: 'Señal',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ControladorStatBox(
                      value: '52',
                      suffix: ' ms',
                      dotColor: const Color(0xFF10B981),
                      label: 'Latencia',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ControladorStatBox(
                      value: '99.4',
                      suffix: ' %',
                      dotColor: const Color(0xFF10B981),
                      label: 'Disponibilidad',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

            ],
          ),
        );
      },
    );
  }
}

// ── Summary Stat Card ────────────────────────────────────────────────────────

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String? valueSuffix;
  final String title;
  final String subtitle;

  const _SummaryStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    this.valueSuffix,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Icon badge
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 16),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground)),
              if (valueSuffix != null)
                Text(valueSuffix!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.foreground)),
            ],
          ),
          const SizedBox(height: 4),

          // Title
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.foreground)),
          const SizedBox(height: 2),

          // Subtitle
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Device Row ───────────────────────────────────────────────────────────────

class _DeviceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final Color statusBgColor;

  const _DeviceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.foreground),
          ),
          const SizedBox(width: 12),

          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Controlador Stat Box ──────────────────────────────────────────────────────

class _ControladorStatBox extends StatelessWidget {
  final String value;
  final String suffix;
  final Color dotColor;
  final String label;

  const _ControladorStatBox({
    required this.value,
    required this.suffix,
    required this.dotColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.foreground)),
              Text(suffix, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 5, height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 9, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: AppColors.mutedForeground,
        ),
      );
}
