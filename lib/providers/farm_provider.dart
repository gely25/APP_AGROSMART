import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/farm_state.dart';

int _eventIdCounter = 0;

FarmEvent _makeEvent(String label) {
  _eventIdCounter++;
  return FarmEvent(id: _eventIdCounter, label: label, at: DateTime.now());
}

const int _maxEvents = 8;

/// ChangeNotifier that replicates the SmartFarmProvider React context.
/// In demo mode (no ESP32), all state is simulated locally.
class FarmProvider extends ChangeNotifier {
  FarmState _state = FarmState(
    connected: true,
    doorState: DoorState.closed,
    feederState: FeederState.closed,
    waterState: WaterState.empty,
    animalDetected: true,
    alarmActive: false,
    lastUpdate: DateTime.now(),
    events: [
      _makeEvent('Conexión establecida con ESP32'),
      _makeEvent('Sistema iniciado'),
      _makeEvent('Animal detectado'),
    ],
  );

  FarmState get state => _state;

  Timer? _sensorTimer;
  Timer? _fillTimer;

  FarmProvider() {
    // Periodic sensor refresh — every 5 seconds (matches React's setInterval)
    _sensorTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final nextAnimal = Random().nextDouble() > 0.25;
      final changed = nextAnimal != _state.animalDetected;
      final label = nextAnimal ? 'Animal detectado' : 'Animal fuera del corral';
      _touch(
        _state.copyWith(
          animalDetected: nextAnimal,
          lastUpdate: DateTime.now(),
        ),
        changed ? label : null,
      );
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _fillTimer?.cancel();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void openDoor() => _touch(
    _state.copyWith(doorState: DoorState.open, lastUpdate: DateTime.now()),
    'Puerta abierta',
  );

  void closeDoor() => _touch(
    _state.copyWith(doorState: DoorState.closed, lastUpdate: DateTime.now()),
    'Puerta cerrada',
  );

  void openFeeder() => _touch(
    _state.copyWith(feederState: FeederState.open, lastUpdate: DateTime.now()),
    'Comedero abierto',
  );

  void closeFeeder() => _touch(
    _state.copyWith(feederState: FeederState.closed, lastUpdate: DateTime.now()),
    'Comedero cerrado',
  );

  void fillWater() {
    _touch(
      _state.copyWith(waterState: WaterState.filling, lastUpdate: DateTime.now()),
      'Bebedero llenándose',
    );
    // Simulate trough finishing after animation (2600 ms — matches React)
    _fillTimer?.cancel();
    _fillTimer = Timer(const Duration(milliseconds: 2600), () {
      if (_state.waterState == WaterState.filling) {
        _touch(
          _state.copyWith(waterState: WaterState.full, lastUpdate: DateTime.now()),
          'Bebedero lleno',
        );
      }
    });
  }

  void emptyWater() => _touch(
    _state.copyWith(waterState: WaterState.empty, lastUpdate: DateTime.now()),
    'Bebedero vaciado',
  );

  void silenceAlarm() => _touch(
    _state.copyWith(alarmActive: false, lastUpdate: DateTime.now()),
    'Alarma silenciada',
  );

  /// Demo-only: simulates ESP32 raising an alert.
  void triggerAlarm() => _touch(
    _state.copyWith(alarmActive: true, lastUpdate: DateTime.now()),
    'Alerta activada',
  );

  // ── Private ───────────────────────────────────────────────────────────────

  void _touch(FarmState newState, [String? eventLabel]) {
    List<FarmEvent> newEvents = _state.events;
    if (eventLabel != null) {
      newEvents = [_makeEvent(eventLabel), ..._state.events]
          .take(_maxEvents)
          .toList();
    }
    _state = newState.copyWith(events: newEvents);
    notifyListeners();
  }
}
