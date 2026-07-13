import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_state.dart';

class Esp32Service {
  /// IP address of the ESP32. Change this to match your network configuration.
  static String baseUrl = 'http://192.168.1.100';

  static const Duration _timeout = Duration(seconds: 5);

  /// GET /status → FarmState
  static Future<FarmState> getStatus() async {
    final uri = Uri.parse('$baseUrl/status');
    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseStatus(json);
    }
    throw Exception('HTTP ${response.statusCode} from /status');
  }

  // ── Door ──────────────────────────────────────────────────────────────────
  static Future<void> openDoor() => _get('/openDoor');
  static Future<void> closeDoor() => _get('/closeDoor');

  // ── Water ─────────────────────────────────────────────────────────────────
  static Future<void> fillWater() => _get('/fillWater');
  static Future<void> emptyWater() => _get('/emptyWater');

  // ── Alarm ─────────────────────────────────────────────────────────────────
  static Future<void> silenceAlarm() => _get('/silenceAlarm');

  // ── Private helpers ───────────────────────────────────────────────────────
  static Future<void> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    await http.get(uri).timeout(_timeout);
  }

  static FarmState _parseStatus(Map<String, dynamic> json) {
    return FarmState(
      connected: json['connected'] as bool? ?? true,
      lastUpdate: DateTime.now(),
      doorState: json['door'] == 'open' ? DoorState.open : DoorState.closed,
      doorOpenCount: (json['doorOpenCount'] as int?) ?? 0,
      doorOpenSeconds: (json['doorOpenSeconds'] as int?) ?? 0,
      doorLastUser: (json['doorLastUser'] as String?) ?? 'Sistema',
      waterState: _parseWater(json['water'] as String?),
      waterPercent: (json['waterPercent'] as num?)?.toDouble() ?? 50.0,
      waterCapacityL: (json['waterCapacityL'] as num?)?.toDouble() ?? 50.0,
      waterDailyConsumptionL: (json['waterDailyConsumptionL'] as num?)?.toDouble() ?? 12.0,
      valveOpen: json['valveOpen'] as bool? ?? false,
      animalDetected: json['animalDetected'] as bool? ?? false,
      lastMotionTime: json['lastMotionTime'] != null
          ? DateTime.tryParse(json['lastMotionTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      pirEventsToday: (json['pirEventsToday'] as int?) ?? 0,
      alarmActive: json['alarm'] as bool? ?? false,
      operationMode: OperationMode.automatic,
      hitlPendingWater: false,
      voltageV: (json['voltageV'] as num?)?.toDouble() ?? 3.28,
      esp32TempC: (json['esp32TempC'] as num?)?.toDouble() ?? 42.0,
      cpuUsagePercent: (json['cpuUsagePercent'] as int?) ?? 15,
      memoryUsedKb: (json['memoryUsedKb'] as int?) ?? 200,
      memoryTotalKb: (json['memoryTotalKb'] as int?) ?? 520,
      latencyMs: (json['latencyMs'] as int?) ?? 20,
      wifiRssi: (json['wifiRssi'] as int?) ?? -62,
      notifications: const [],
      auditLog: const [],
      events: const [],
    );
  }

  static WaterState _parseWater(String? value) {
    switch (value) {
      case 'full':    return WaterState.full;
      case 'filling': return WaterState.filling;
      default:        return WaterState.empty;
    }
  }
}
