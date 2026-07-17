import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

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
              // Overall health
              _OverallHealthCard(state: s),
              const SizedBox(height: 14),

              // ── Network section
              _SectionLabel('RED Y CONECTIVIDAD'),
              const SizedBox(height: 10),
              _DiagCard(children: [
                _DiagRow(label: 'Estado ESP32', value: s.connected ? 'Operativo' : 'Sin conexión',
                    indicator: s.connected ? _Indicator.green : _Indicator.red),
                _DiagRow(label: 'RSSI WiFi', value: '${s.wifiRssi} dBm',
                    indicator: s.wifiRssi > -65 ? _Indicator.green : s.wifiRssi > -80 ? _Indicator.yellow : _Indicator.red),
                _DiagRow(label: 'Latencia', value: '${s.latencyMs} ms',
                    indicator: s.latencyMs < 30 ? _Indicator.green : s.latencyMs < 80 ? _Indicator.yellow : _Indicator.red),
                _DiagRow(label: 'Dirección IP', value: provider.activeCorral?.ip ?? '—', indicator: _Indicator.green),
                _DiagRow(label: 'Protocolo', value: 'HTTP/REST · WiFi', indicator: _Indicator.green),
              ]),
              const SizedBox(height: 14),

              // ── Hardware
              _SectionLabel('HARDWARE ESP32'),
              const SizedBox(height: 10),
              _DiagCard(children: [
                _DiagRow(label: 'Modelo', value: 'ESP32 DevKit V1', indicator: _Indicator.green),
                _DiagRow(label: 'Firmware', value: provider.activeCorral?.firmware ?? 'v1.0.0', indicator: _Indicator.green),
                _DiagRow(label: 'Modo operación', value: s.operationMode == OperationMode.automatic ? 'Automático' : 'Manual', indicator: _Indicator.green),
              ]),
              const SizedBox(height: 14),

              // ── Sensors
              _SectionLabel('SENSORES Y ACTUADORES'),
              const SizedBox(height: 10),
              _DiagCard(children: [
                _DiagRow(label: 'Sensor PIR (HC-SR501)', value: s.animalDetected ? '⚡ Movimiento detectado' : 'Standby',
                    indicator: s.animalDetected ? _Indicator.yellow : _Indicator.green),
                _DiagRow(label: 'Servo puerta (MG996R)', value: s.doorState == DoorState.open ? 'Posición: Abierta' : 'Posición: Cerrada',
                    indicator: _Indicator.green),
                _DiagRow(label: 'Sensor flotador', value: s.waterState == WaterState.full ? 'Nivel OK' : 'Nivel Bajo',
                    indicator: s.waterState == WaterState.full ? _Indicator.green : _Indicator.red),
                _DiagRow(label: 'Bomba de agua', value: s.valveOpen ? 'Activa (Llenando)' : 'Apagada',
                    indicator: s.valveOpen ? _Indicator.yellow : _Indicator.green),
                _DiagRow(label: 'Pantalla OLED', value: 'SSD1306 — Activa', indicator: _Indicator.green),
              ]),
              const SizedBox(height: 14),

              // ── Availability
              _SectionLabel('DISPONIBILIDAD DEL SISTEMA'),
              const SizedBox(height: 10),
              _AvailabilityCard(uptime: provider.uptime, connected: s.connected),
            ],
          ),
        );
      },
    );
  }
}

// ── Overall Health Card ──────────────────────────────────────────────────────

class _OverallHealthCard extends StatelessWidget {
  final FarmState state;
  const _OverallHealthCard({required this.state});

  _Indicator get _overall {
    if (!state.connected) return _Indicator.red;
    if (state.alarmActive || state.waterState == WaterState.empty || state.latencyMs > 80) return _Indicator.yellow;
    return _Indicator.green;
  }

  String get _statusText {
    if (!state.connected) return 'Sistema desconectado';
    if (state.alarmActive) return 'Alarma activa — atención requerida';
    if (state.waterState == WaterState.empty) return 'Bebedero vacío — verificar flotador';
    if (state.latencyMs > 80) return 'Latencia elevada';
    return 'Sistema operando con normalidad';
  }

  @override
  Widget build(BuildContext context) {
    final ind = _overall;
    final color = ind == _Indicator.green
        ? AppColors.success
        : ind == _Indicator.yellow
            ? AppColors.warning
            : AppColors.destructive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              ind == _Indicator.green ? Icons.check_circle_rounded
                  : ind == _Indicator.yellow ? Icons.warning_rounded
                  : Icons.error_rounded,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ind == _Indicator.green ? 'Sistema Saludable'
                      : ind == _Indicator.yellow ? 'Atención recomendada'
                      : 'Error detectado',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 3),
                Text(_statusText, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
              ],
            ),
          ),
          _TrafficLight(indicator: ind),
        ],
      ),
    );
  }
}



// ── Availability Card ─────────────────────────────────────────────────────────

class _AvailabilityCard extends StatelessWidget {
  final String uptime;
  final bool connected;
  const _AvailabilityCard({required this.uptime, required this.connected});

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
          Row(
            children: [
              Expanded(
                child: _AvailStat(
                  label: 'Estado',
                  value: connected ? 'Conectado' : 'Desconectado',
                  color: connected ? AppColors.success : AppColors.destructive,
                ),
              ),
              Expanded(
                child: _AvailStat(label: 'Tiempo activo', value: uptime, color: AppColors.info),
              ),
              Expanded(
                child: _AvailStat(
                  label: 'Protocolo',
                  value: 'HTTP',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.wifi_rounded, size: 13, color: AppColors.mutedForeground),
              SizedBox(width: 6),
              Text('Comunicación local · Red WiFi compartida · Polling cada 2s',
                  style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AvailStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.mutedForeground), textAlign: TextAlign.center),
      ],
    );
  }
}

// ── Diag Helpers ──────────────────────────────────────────────────────────────

class _DiagCard extends StatelessWidget {
  final List<Widget> children;
  const _DiagCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children.indexed.map((e) {
          final i = e.$1;
          return Column(
            children: [
              e.$2,
              if (i < children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Container(height: 1, color: AppColors.border),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

enum _Indicator { green, yellow, red }

class _DiagRow extends StatelessWidget {
  final String label;
  final String value;
  final _Indicator indicator;

  const _DiagRow({required this.label, required this.value, required this.indicator});

  Color get _color {
    switch (indicator) {
      case _Indicator.green: return AppColors.success;
      case _Indicator.yellow: return AppColors.warning;
      case _Indicator.red: return AppColors.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.foreground),
          ),
        ],
      ),
    );
  }
}

class _TrafficLight extends StatelessWidget {
  final _Indicator indicator;
  const _TrafficLight({required this.indicator});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Dot(color: AppColors.destructive, active: indicator == _Indicator.red),
        const SizedBox(height: 3),
        _Dot(color: AppColors.warning, active: indicator == _Indicator.yellow),
        const SizedBox(height: 3),
        _Dot(color: AppColors.success, active: indicator == _Indicator.green),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final bool active;
  const _Dot({required this.color, required this.active});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : color.withOpacity(0.15),
        boxShadow: active ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)] : [],
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
