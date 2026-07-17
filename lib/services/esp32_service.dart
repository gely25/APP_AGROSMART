import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_state.dart';

class Esp32Service {
  /// IP address of the ESP32. Change this to match your network configuration.
  static String baseUrl = 'http://10.16.146.175';

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
  static Future<void> setDoorParams(int openTime, int maxOpen) =>
      _get('/setDoorParams?openTime=$openTime&maxOpen=$maxOpen');


  // ── Water ─────────────────────────────────────────────────────────────────
  static Future<void> fillWater() => _get('/fillWater');
  static Future<void> emptyWater() => _get('/emptyWater');

  // ── Alarm ─────────────────────────────────────────────────────────────────
  static Future<void> silenceAlarm() => _get('/silenceAlarm');

  // ── Mode ──────────────────────────────────────────────────────────────────
  static Future<void> setMode(String mode) => _get('/setMode?mode=$mode');

  // ── Private helpers ───────────────────────────────────────────────────────
  static Future<void> _get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      await http.get(uri).timeout(_timeout);
    } catch (e) {
      // Catch exceptions silently or rethrow depending on needs, but let's rethrow to let provider handle connection state
      rethrow;
    }
  }

  static FarmState _parseStatus(Map<String, dynamic> json) {
    final modeStr = json['mode'] as String? ?? 'auto';
    final isManual = modeStr == 'manual';
    
    return FarmState(
      connected: true,
      lastUpdate: DateTime.now(),
      doorState: json['door'] == 'open' ? DoorState.open : DoorState.closed,
      doorOpenCount: 0, // Calculated or stored in provider
      doorOpenSeconds: 0, // Calculated or stored in provider
      doorLastUser: isManual ? 'Operador' : 'Sistema',
      waterState: json['water'] == 'full' ? WaterState.full : WaterState.empty,
      waterPercent: json['water'] == 'full' ? 100.0 : 10.0,
      waterCapacityL: 50.0,
      waterDailyConsumptionL: 12.0,
      valveOpen: json['pump'] as bool? ?? false,
      animalDetected: json['motion'] as bool? ?? false,
      lastMotionTime: DateTime.now(),
      pirEventsToday: 0,
      alarmActive: false,
      operationMode: isManual ? OperationMode.manual : OperationMode.automatic,
      hitlPendingWater: false,
      voltageV: 3.3, // Fixed ESP32 operating voltage
      esp32TempC: 0.0, // Internal temp not measured
      cpuUsagePercent: 0, // Not monitored
      memoryUsedKb: 0, // Not monitored
      memoryTotalKb: 520,
      latencyMs: 0, // Calculated dynamically in provider
      wifiRssi: json['rssi'] as int? ?? -60,
      notifications: const [],
      auditLog: const [],
      events: const [],
    );
  }
}

