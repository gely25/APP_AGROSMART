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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero ────────────────────────────────────────────────────────
              _HeroBanner(state: s, uptime: provider.uptime),
              const SizedBox(height: 16),

              // ── Centro de Decisiones ─────────────────────────────────────
              _DecisionCenter(messages: s.decisionMessages),
              const SizedBox(height: 16),

              // ── Status Grid ───────────────────────────────────────────────
              _SectionLabel('ESTADO DEL SISTEMA'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.15,
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
                    tone: s.doorState == DoorState.open ? StatusTone.success : StatusTone.neutral,
                  ),
                  StatusCard(
                    icon: Icons.sensors_rounded,
                    title: 'Sensor PIR',
                    value: s.animalDetected ? 'Movimiento' : 'Sin movimiento',
                    tone: s.animalDetected ? StatusTone.alert : StatusTone.neutral,
                    pulse: s.animalDetected,
                  ),
                  StatusCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Bebedero',
                    value: s.waterState == WaterState.full
                        ? 'Lleno'
                        : s.waterState == WaterState.filling
                            ? 'Llenándose'
                            : 'Bajo',
                    tone: s.waterLow
                        ? StatusTone.alert
                        : s.waterState == WaterState.filling
                            ? StatusTone.info
                            : StatusTone.success,
                  ),
                  StatusCard(
                    icon: s.alarmActive
                        ? Icons.notifications_active_outlined
                        : Icons.shield_outlined,
                    title: 'Alarma',
                    value: s.alarmActive ? 'Activada' : 'Sin alertas',
                    tone: s.alarmActive ? StatusTone.alert : StatusTone.success,
                    pulse: s.alarmActive,
                  ),
                  StatusCard(
                    icon: Icons.auto_fix_high_rounded,
                    title: 'Modo',
                    value: s.operationMode == OperationMode.automatic
                        ? 'Automático'
                        : s.operationMode == OperationMode.humanInTheLoop
                            ? 'HITL'
                            : 'Manual',
                    tone: StatusTone.info,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Quick Stats Bar ───────────────────────────────────────────
              _SectionLabel('ESTADÍSTICAS DEL DÍA'),
              const SizedBox(height: 10),
              _QuickStats(state: s),
              const SizedBox(height: 16),

              // ── ESP32 Telemetría ──────────────────────────────────────────
              _SectionLabel('ESTADO ESP32'),
              const SizedBox(height: 10),
              _Esp32Card(state: s, uptime: provider.uptime, lastSync: timeStr),
              const SizedBox(height: 16),

              // ── Mini Charts ───────────────────────────────────────────────
              _SectionLabel('RESUMEN GRÁFICO'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _WaterChart(percent: s.waterPercent)),
                  const SizedBox(width: 10),
                  Expanded(child: _PirChart(eventsToday: s.pirEventsToday, doorCount: s.doorOpenCount)),
                ],
              ),
              const SizedBox(height: 16),

              // ── Recent Events ─────────────────────────────────────────────
              _SectionLabel('HISTORIAL RECIENTE'),
              const SizedBox(height: 10),
              _RecentEvents(events: s.events),
            ],
          ),
        );
      },
    );
  }
}

// ── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final FarmState state;
  final String uptime;

  const _HeroBanner({required this.state, required this.uptime});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          SizedBox(
            height: 150,
            child: Image.asset(
              'assets/images/corral_illustration.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.primary.withOpacity(0.80)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14, left: 16, right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.alarmActive ? 'Atención requerida' : 'Todo funciona con normalidad',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text('Uptime: $uptime', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.80))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.connected ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        state.connected ? 'EN LÍNEA' : 'OFFLINE',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                      ),
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

// ── Decision Center ──────────────────────────────────────────────────────────

class _DecisionCenter extends StatelessWidget {
  final List<String> messages;
  const _DecisionCenter({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Text('Centro de Decisiones',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.border),
          ...messages.map((msg) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Text(msg, style: const TextStyle(fontSize: 12, color: AppColors.foreground, height: 1.4)),
          )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Quick Stats Bar ──────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  final FarmState state;
  const _QuickStats({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickStatBox(
          label: 'Aperturas hoy',
          value: '${state.doorOpenCount}',
          icon: Icons.door_front_door_outlined,
          color: AppColors.info,
        ),
        const SizedBox(width: 8),
        _QuickStatBox(
          label: 'Eventos PIR',
          value: '${state.pirEventsToday}',
          icon: Icons.sensors_rounded,
          color: AppColors.warning,
        ),
        const SizedBox(width: 8),
        _QuickStatBox(
          label: 'Agua',
          value: '${state.waterPercent.toStringAsFixed(0)}%',
          icon: Icons.water_drop_outlined,
          color: state.waterLow ? AppColors.destructive : AppColors.success,
        ),
        const SizedBox(width: 8),
        _QuickStatBox(
          label: 'Disponib.',
          value: '99.8%',
          icon: Icons.timelapse_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _QuickStatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _QuickStatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.mutedForeground), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── ESP32 Card ───────────────────────────────────────────────────────────────

class _Esp32Card extends StatelessWidget {
  final FarmState state;
  final String uptime;
  final String lastSync;
  const _Esp32Card({required this.state, required this.uptime, required this.lastSync});

  @override
  Widget build(BuildContext context) {
    Color rssiColor(int v) {
      if (v > -65) return AppColors.success;
      if (v > -80) return AppColors.warning;
      return AppColors.destructive;
    }
    Color latencyColor(int v) {
      if (v < 30) return AppColors.success;
      if (v < 80) return AppColors.warning;
      return AppColors.destructive;
    }
    Color voltageColor(double v) {
      if (v > 3.1) return AppColors.success;
      if (v > 2.8) return AppColors.warning;
      return AppColors.destructive;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Esp32Metric(label: 'RSSI', value: '${state.wifiRssi}dBm', color: rssiColor(state.wifiRssi)),
              _Esp32Metric(label: 'Latencia', value: '${state.latencyMs}ms', color: latencyColor(state.latencyMs)),
              _Esp32Metric(label: 'Voltaje', value: '${state.voltageV.toStringAsFixed(2)}V', color: voltageColor(state.voltageV)),
              _Esp32Metric(label: 'Firmware', value: 'v1.0.0', color: AppColors.foreground),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 13, color: AppColors.mutedForeground),
              const SizedBox(width: 6),
              Text('Uptime: $uptime', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              const Spacer(),
              const Icon(Icons.sync_rounded, size: 13, color: AppColors.mutedForeground),
              const SizedBox(width: 4),
              Text('Sync: $lastSync', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Esp32Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Esp32Metric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ── Mini Charts ──────────────────────────────────────────────────────────────

class _WaterChart extends StatelessWidget {
  final double percent;
  const _WaterChart({required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = percent < 20 ? AppColors.destructive : percent < 50 ? AppColors.warning : AppColors.info;
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
            children: [
              Icon(Icons.water_drop_rounded, size: 13, color: color),
              const SizedBox(width: 5),
              const Text('Bebedero', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 70, height: 70,
              child: CustomPaint(
                painter: _CircleProgressPainter(value: percent / 100, color: color),
                child: Center(
                  child: Text(
                    '${percent.toInt()}%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percent < 20 ? '⚠️ Nivel crítico' : 'Nivel normal',
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  const _CircleProgressPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final bgPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -pi/2
      value * 6.2832,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) => old.value != value || old.color != color;
}

class _PirChart extends StatelessWidget {
  final int eventsToday;
  final int doorCount;
  const _PirChart({required this.eventsToday, required this.doorCount});

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
            children: const [
              Icon(Icons.bar_chart_rounded, size: 13, color: AppColors.warning),
              SizedBox(width: 5),
              Text('Actividad', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          _BarItem(label: 'PIR hoy', value: eventsToday, maxValue: 20, color: AppColors.warning),
          const SizedBox(height: 8),
          _BarItem(label: 'Aperturas', value: doorCount, maxValue: 10, color: AppColors.info),
          const SizedBox(height: 8),
          const Text('Últimas 24 horas',
              style: TextStyle(fontSize: 9, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  const _BarItem({required this.label, required this.value, required this.maxValue, required this.color});

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxValue).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
            const Spacer(),
            Text('$value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Recent Events ────────────────────────────────────────────────────────────

class _RecentEvents extends StatelessWidget {
  final List<FarmEvent> events;
  const _RecentEvents({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text('Sin eventos recientes', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: events.take(5).indexed.map((entry) {
          final i = entry.$1;
          final event = entry.$2;
          final timeStr = DateFormat('HH:mm').format(event.at);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(event.label,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.foreground)),
                    ),
                    Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              if (i < (events.length - 1).clamp(0, 4))
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Container(height: 1, color: AppColors.border),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: AppColors.mutedForeground,
      ));
}
