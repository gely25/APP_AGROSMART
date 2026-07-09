
enum DoorState { closed, open }
enum FeederState { closed, open }
enum WaterState { empty, filling, full }

class FarmEvent {
  final int id;
  final String label;
  final DateTime at;

  const FarmEvent({required this.id, required this.label, required this.at});
}

class FarmState {
  final bool connected;
  final DoorState doorState;
  final FeederState feederState;
  final WaterState waterState;
  final bool animalDetected;
  final bool alarmActive;
  final DateTime lastUpdate;
  final List<FarmEvent> events;

  const FarmState({
    required this.connected,
    required this.doorState,
    required this.feederState,
    required this.waterState,
    required this.animalDetected,
    required this.alarmActive,
    required this.lastUpdate,
    required this.events,
  });

  FarmState copyWith({
    bool? connected,
    DoorState? doorState,
    FeederState? feederState,
    WaterState? waterState,
    bool? animalDetected,
    bool? alarmActive,
    DateTime? lastUpdate,
    List<FarmEvent>? events,
  }) {
    return FarmState(
      connected: connected ?? this.connected,
      doorState: doorState ?? this.doorState,
      feederState: feederState ?? this.feederState,
      waterState: waterState ?? this.waterState,
      animalDetected: animalDetected ?? this.animalDetected,
      alarmActive: alarmActive ?? this.alarmActive,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      events: events ?? this.events,
    );
  }

  String get systemMessage {
    if (!connected) return 'Sin conexión con el ESP32.';
    if (alarmActive) return 'Atención requerida en el corral.';
    if (waterState == WaterState.empty) return 'Bebedero vacío, revisar suministro.';
    return 'Todos los sistemas funcionando correctamente.';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FarmState &&
        other.connected == connected &&
        other.doorState == doorState &&
        other.feederState == feederState &&
        other.waterState == waterState &&
        other.animalDetected == animalDetected &&
        other.alarmActive == alarmActive &&
        other.lastUpdate == lastUpdate;
  }

  @override
  int get hashCode => Object.hash(
    connected, doorState, feederState, waterState,
    animalDetected, alarmActive, lastUpdate,
  );
}
