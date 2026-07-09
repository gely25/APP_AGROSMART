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

  // ── Feeder ────────────────────────────────────────────────────────────────
  static Future<void> openFeeder() => _get('/openFeeder');
  static Future<void> closeFeeder() => _get('/closeFeeder');

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
      doorState: json['door'] == 'open' ? DoorState.open : DoorState.closed,
      feederState: json['feeder'] == 'open' ? FeederState.open : FeederState.closed,
      waterState: _parseWater(json['water'] as String?),
      animalDetected: json['animalDetected'] as bool? ?? false,
      alarmActive: json['alarm'] as bool? ?? false,
      lastUpdate: DateTime.now(),
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
