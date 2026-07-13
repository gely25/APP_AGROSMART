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

  const CorralInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.macAddress,
    required this.ip,
    required this.firmware,
    required this.rssi,
    required this.availability,
  });

  CorralInfo copyWith({
    String? name,
    String? description,
    String? ip,
    int? rssi,
    double? availability,
  }) => CorralInfo(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    macAddress: macAddress,
    ip: ip ?? this.ip,
    firmware: firmware,
    rssi: rssi ?? this.rssi,
    availability: availability ?? this.availability,
  );
}

// ── Legacy FarmEvent ───────────────────────────────────────────────────────

class FarmEvent {
  final int id;
  final String label;
  final DateTime at;

  const FarmEvent({required this.id, required this.label, required this.at});
}

// ── Main FarmState ─────────────────────────────────────────────────────────

class FarmState {
  // Connection
  final bool connected;
  final DateTime lastUpdate;

  // Hardware: Door
  final DoorState doorState;
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
