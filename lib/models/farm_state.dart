// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart' show TimeOfDay;

enum DoorState { closed, open, moving }

enum WaterState { empty, filling, full }

enum OperationMode { manual, automatic, humanInTheLoop }

enum NotificationType {
  motion,
  waterLow,
  esp32Disconnected,
  esp32Reconnected,
  doorOpened,
  doorClosed,
  waterFilled,
  incident,
}

enum AuditEventType {
  system,
  door,
  water,
  pir,
  alarm,
  automation,
  user,
  network,
}

// ── Notification Model ─────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime at;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.at,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    at: at,
    isRead: isRead ?? this.isRead,
  );
}

// ── Audit Event Model ──────────────────────────────────────────────────────

class AuditEvent {
  final String id;
  final AuditEventType type;
  final String action;
  final String detail;
  final String user;
  final String origin; // 'Manual', 'Automático', 'Sistema', 'Sensor'
  final DateTime at;
  final Duration? duration;
  final bool success;
  // Extended audit fields
  final String? corral;   // Name of the corral where the event happened
  final String? device;  // Specific device (e.g. 'Puerta #1', 'Bebedero #1', 'Sensor PIR')
  final String? result;  // Human-readable result (e.g. 'Exitoso', 'Fallo', 'Timeout')

  const AuditEvent({
    required this.id,
    required this.type,
    required this.action,
    required this.detail,
    required this.user,
    required this.origin,
    required this.at,
    this.duration,
    this.success = true,
    this.corral,
    this.device,
    this.result,
  });
}

// ── Automation Rule Model ──────────────────────────────────────────────────

class AutomationRule {
  final String id;
  final String condition; // e.g. 'water_below_20'
  final String conditionLabel;
  final String action;
  final String actionLabel;
  final bool enabled;
  final bool requiresHITL;

  const AutomationRule({
    required this.id,
    required this.condition,
    required this.conditionLabel,
    required this.action,
    required this.actionLabel,
    required this.enabled,
    required this.requiresHITL,
  });

  AutomationRule copyWith({bool? enabled, bool? requiresHITL}) => AutomationRule(
    id: id,
    condition: condition,
    conditionLabel: conditionLabel,
    action: action,
    actionLabel: actionLabel,
    enabled: enabled ?? this.enabled,
    requiresHITL: requiresHITL ?? this.requiresHITL,
  );
}

// ── Schedule Model ─────────────────────────────────────────────────────────

class AutomationSchedule {
  final String id;
  final String label;
  final TimeOfDay time;
  final List<bool> days; // Mon..Sun
  final String action;
  final bool enabled;

  const AutomationSchedule({
    required this.id,
    required this.label,
    required this.time,
    required this.days,
    required this.action,
    required this.enabled,
  });

  AutomationSchedule copyWith({bool? enabled}) => AutomationSchedule(
    id: id,
    label: label,
    time: time,
    days: days,
    action: action,
    enabled: enabled ?? this.enabled,
  );
}

// ── Corral Model ───────────────────────────────────────────────────────────

class CorralInfo {
  final String id;
  final String name;
  final String description;
  final String macAddress;
  final String ip;
  final String firmware;
  final int rssi;
  final double availability;

  // Estado del controlador (para "Mis Corrales" y el Centro de Dispositivos)
  final bool connected;
  final DateTime lastSyncAt;
  final int eventCount;

  // Dispositivos del corral. Hoy normalmente 1 de cada uno, pero la lista
  // permite escalar a "+ Nueva puerta / + Nuevo bebedero / + Nuevo sensor".
  final List<DoorDevice> doors;
  final List<WatererDevice> waterers;
  final List<SensorDevice> sensors;

  const CorralInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.macAddress,
    required this.ip,
    required this.firmware,
    required this.rssi,
    required this.availability,
    this.connected = true,
    required this.lastSyncAt,
    this.eventCount = 0,
    this.doors = const [],
    this.waterers = const [],
    this.sensors = const [],
  });

  CorralInfo copyWith({
    String? name,
    String? description,
    String? ip,
    int? rssi,
    double? availability,
    bool? connected,
    DateTime? lastSyncAt,
    int? eventCount,
    List<DoorDevice>? doors,
    List<WatererDevice>? waterers,
    List<SensorDevice>? sensors,
  }) => CorralInfo(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    macAddress: macAddress,
    ip: ip ?? this.ip,
    firmware: firmware,
    rssi: rssi ?? this.rssi,
    availability: availability ?? this.availability,
    connected: connected ?? this.connected,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    eventCount: eventCount ?? this.eventCount,
    doors: doors ?? this.doors,
    waterers: waterers ?? this.waterers,
    sensors: sensors ?? this.sensors,
  );
}

// ── Legacy FarmEvent ───────────────────────────────────────────────────────

class FarmEvent {
  final int id;
  final String label;
  final DateTime at;

  const FarmEvent({required this.id, required this.label, required this.at});
}

// ── Device Models (multi-corral / multi-device architecture) ──────────────
//
// Cada Corral puede tener varias puertas, bebederos y sensores. Hoy solo
// existe un dispositivo funcional de cada tipo (ver FarmProvider), pero el
// modelo ya soporta listas para escalar sin volver a romper la arquitectura.

class DoorDevice {
  final String id;
  final String name;
  final DoorState state;
  final OperationMode mode;
  final int openCount;
  final int openSeconds;
  final String lastUser;
  final DateTime? lastOpenedAt;

  const DoorDevice({
    required this.id,
    required this.name,
    required this.state,
    required this.mode,
    required this.openCount,
    required this.openSeconds,
    required this.lastUser,
    this.lastOpenedAt,
  });

  DoorDevice copyWith({
    DoorState? state,
    OperationMode? mode,
    int? openCount,
    int? openSeconds,
    String? lastUser,
    DateTime? lastOpenedAt,
  }) => DoorDevice(
    id: id,
    name: name,
    state: state ?? this.state,
    mode: mode ?? this.mode,
    openCount: openCount ?? this.openCount,
    openSeconds: openSeconds ?? this.openSeconds,
    lastUser: lastUser ?? this.lastUser,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
}

class WatererDevice {
  final String id;
  final String name;
  final WaterState state;
  final double percent; // 0..100
  final double capacityL;
  final double dailyConsumptionL;
  final bool valveOpen;
  final DateTime? lastFilledAt;

  const WatererDevice({
    required this.id,
    required this.name,
    required this.state,
    required this.percent,
    required this.capacityL,
    required this.dailyConsumptionL,
    required this.valveOpen,
    this.lastFilledAt,
  });

  double get liters => capacityL * percent / 100;
  bool get low => percent < 20;

  /// Estimated hours remaining until this waterer hits 10%
  double get autonomyHours {
    if (dailyConsumptionL <= 0) return 999;
    final remaining = liters - (capacityL * 0.10);
    if (remaining <= 0) return 0;
    return (remaining / dailyConsumptionL) * 24;
  }

  WatererDevice copyWith({
    WaterState? state,
    double? percent,
    double? capacityL,
    double? dailyConsumptionL,
    bool? valveOpen,
    DateTime? lastFilledAt,
  }) => WatererDevice(
    id: id,
    name: name,
    state: state ?? this.state,
    percent: percent ?? this.percent,
    capacityL: capacityL ?? this.capacityL,
    dailyConsumptionL: dailyConsumptionL ?? this.dailyConsumptionL,
    valveOpen: valveOpen ?? this.valveOpen,
    lastFilledAt: lastFilledAt ?? this.lastFilledAt,
  );
}

class SensorDevice {
  final String id;
  final String name;
  final String zone;
  final bool detected;
  final DateTime lastMotionTime;
  final int eventsToday;
  final int sensitivity; // 0..100

  const SensorDevice({
    required this.id,
    required this.name,
    required this.zone,
    required this.detected,
    required this.lastMotionTime,
    required this.eventsToday,
    required this.sensitivity,
  });

  SensorDevice copyWith({
    bool? detected,
    DateTime? lastMotionTime,
    int? eventsToday,
    int? sensitivity,
  }) => SensorDevice(
    id: id,
    name: name,
    zone: zone,
    detected: detected ?? this.detected,
    lastMotionTime: lastMotionTime ?? this.lastMotionTime,
    eventsToday: eventsToday ?? this.eventsToday,
    sensitivity: sensitivity ?? this.sensitivity,
  );
}

// ── Main FarmState ─────────────────────────────────────────────────────────

class FarmState {
  // Connection
  final bool connected;
  final DateTime lastUpdate;

  // Hardware: Door
  final DoorState doorState;
  final DoorState? doorTarget; // set while doorState == moving: where it's headed
  final int doorOpenCount;
  final int doorOpenSeconds;
  final String doorLastUser;
  final DateTime? doorLastOpenedAt;

  // Hardware: Water
  final WaterState waterState;
  final double waterPercent;     // 0..100
  final double waterCapacityL;
  final double waterDailyConsumptionL;
  final bool valveOpen;
  final DateTime? waterLastFilledAt;

  // Hardware: PIR
  final bool animalDetected;
  final DateTime lastMotionTime;
  final int pirEventsToday;

  // Alarm
  final bool alarmActive;

  // Operation Mode
  final OperationMode operationMode;
  final bool hitlPendingWater;    // waiting for user approval to fill

  // ESP32 Telemetry
  final double voltageV;
  final double esp32TempC;
  final int cpuUsagePercent;
  final int memoryUsedKb;
  final int memoryTotalKb;
  final int latencyMs;
  final int wifiRssi;

  // Notifications
  final List<AppNotification> notifications;

  // Audit log
  final List<AuditEvent> auditLog;

  // Legacy events for Dashboard summary
  final List<FarmEvent> events;

  const FarmState({
    required this.connected,
    required this.lastUpdate,
    required this.doorState,
    this.doorTarget,
    required this.doorOpenCount,
    required this.doorOpenSeconds,
    required this.doorLastUser,
    this.doorLastOpenedAt,
    required this.waterState,
    required this.waterPercent,
    required this.waterCapacityL,
    required this.waterDailyConsumptionL,
    required this.valveOpen,
    this.waterLastFilledAt,
    required this.animalDetected,
    required this.lastMotionTime,
    required this.pirEventsToday,
    required this.alarmActive,
    required this.operationMode,
    required this.hitlPendingWater,
    required this.voltageV,
    required this.esp32TempC,
    required this.cpuUsagePercent,
    required this.memoryUsedKb,
    required this.memoryTotalKb,
    required this.latencyMs,
    required this.wifiRssi,
    required this.notifications,
    required this.auditLog,
    required this.events,
  });

  double get memoryUsedPercent =>
      memoryTotalKb > 0 ? (memoryUsedKb / memoryTotalKb * 100) : 0;

  double get waterLiters => waterCapacityL * waterPercent / 100;

  /// Estimated hours remaining until water hits 10%
  double get waterAutonomyHours {
    if (waterDailyConsumptionL <= 0) return 999;
    final remaining = waterLiters - (waterCapacityL * 0.10);
    if (remaining <= 0) return 0;
    return (remaining / waterDailyConsumptionL) * 24;
  }

  bool get waterLow => waterPercent < 20;

  List<String> get decisionMessages {
    final now = DateTime.now();
    final messages = <String>[];
    if (!connected) {
      messages.add('⚠️ Sin conexión con el ESP32. Verificar red WiFi.');
      return messages;
    }
    if (alarmActive) {
      messages.add('🚨 Alarma activa en el corral. Atención requerida.');
    }
    if (animalDetected) {
      final secs = now.difference(lastMotionTime).inSeconds;
      messages.add('👁️ Movimiento detectado hace ${secs}s. Revisar acceso.');
    }
    if (waterLow) {
      final hrs = waterAutonomyHours;
      if (hrs < 2) {
        messages.add('💧 Agua crítica ($waterPercent%). Se estima menos de ${hrs.toStringAsFixed(1)}h de autonomía.');
      } else {
        messages.add('💧 Agua baja ($waterPercent%). Autonomía estimada: ${hrs.toStringAsFixed(1)}h.');
      }
    }
    if (latencyMs > 80) {
      messages.add('📡 Latencia elevada (${latencyMs}ms). El ESP32 podría estar saturado.');
    }
    if (doorState == DoorState.open) {
      final mins = doorLastOpenedAt != null
          ? now.difference(doorLastOpenedAt!).inMinutes
          : 0;
      messages.add('🚪 Puerta abierta hace ${mins}min. Última apertura por $doorLastUser.');
    }
    if (pirEventsToday > 10) {
      messages.add('📊 Se registraron $pirEventsToday eventos PIR hoy. Actividad elevada.');
    }
    if (messages.isEmpty) {
      messages.add('✅ Todos los sistemas operan correctamente.');
      messages.add('📡 RSSI: ${wifiRssi}dBm · Latencia: ${latencyMs}ms · Voltaje: ${voltageV.toStringAsFixed(2)}V');
    }
    return messages;
  }

  FarmState copyWith({
    bool? connected,
    DateTime? lastUpdate,
    DoorState? doorState,
    DoorState? doorTarget,
    bool clearDoorTarget = false,
    int? doorOpenCount,
    int? doorOpenSeconds,
    String? doorLastUser,
    DateTime? doorLastOpenedAt,
    WaterState? waterState,
    double? waterPercent,
    double? waterCapacityL,
    double? waterDailyConsumptionL,
    bool? valveOpen,
    DateTime? waterLastFilledAt,
    bool? animalDetected,
    DateTime? lastMotionTime,
    int? pirEventsToday,
    bool? alarmActive,
    OperationMode? operationMode,
    bool? hitlPendingWater,
    double? voltageV,
    double? esp32TempC,
    int? cpuUsagePercent,
    int? memoryUsedKb,
    int? memoryTotalKb,
    int? latencyMs,
    int? wifiRssi,
    List<AppNotification>? notifications,
    List<AuditEvent>? auditLog,
    List<FarmEvent>? events,
  }) {
    return FarmState(
      connected: connected ?? this.connected,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      doorState: doorState ?? this.doorState,
      doorTarget: clearDoorTarget ? null : (doorTarget ?? this.doorTarget),
      doorOpenCount: doorOpenCount ?? this.doorOpenCount,
      doorOpenSeconds: doorOpenSeconds ?? this.doorOpenSeconds,
      doorLastUser: doorLastUser ?? this.doorLastUser,
      doorLastOpenedAt: doorLastOpenedAt ?? this.doorLastOpenedAt,
      waterState: waterState ?? this.waterState,
      waterPercent: waterPercent ?? this.waterPercent,
      waterCapacityL: waterCapacityL ?? this.waterCapacityL,
      waterDailyConsumptionL: waterDailyConsumptionL ?? this.waterDailyConsumptionL,
      valveOpen: valveOpen ?? this.valveOpen,
      waterLastFilledAt: waterLastFilledAt ?? this.waterLastFilledAt,
      animalDetected: animalDetected ?? this.animalDetected,
      lastMotionTime: lastMotionTime ?? this.lastMotionTime,
      pirEventsToday: pirEventsToday ?? this.pirEventsToday,
      alarmActive: alarmActive ?? this.alarmActive,
      operationMode: operationMode ?? this.operationMode,
      hitlPendingWater: hitlPendingWater ?? this.hitlPendingWater,
      voltageV: voltageV ?? this.voltageV,
      esp32TempC: esp32TempC ?? this.esp32TempC,
      cpuUsagePercent: cpuUsagePercent ?? this.cpuUsagePercent,
      memoryUsedKb: memoryUsedKb ?? this.memoryUsedKb,
      memoryTotalKb: memoryTotalKb ?? this.memoryTotalKb,
      latencyMs: latencyMs ?? this.latencyMs,
      wifiRssi: wifiRssi ?? this.wifiRssi,
      notifications: notifications ?? this.notifications,
      auditLog: auditLog ?? this.auditLog,
      events: events ?? this.events,
    );
  }
}