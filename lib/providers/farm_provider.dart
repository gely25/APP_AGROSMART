import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/farm_state.dart';

int _evtId = 0;
String _uid() => 'evt_${++_evtId}_${DateTime.now().millisecondsSinceEpoch}';

FarmEvent _makeEvent(String label) =>
    FarmEvent(id: _evtId++, label: label, at: DateTime.now());

AuditEvent _makeAudit({
  required AuditEventType type,
  required String action,
  required String detail,
  String user = 'Sistema',
  String origin = 'Sistema',
  Duration? duration,
  bool success = true,
}) => AuditEvent(
  id: _uid(),
  type: type,
  action: action,
  detail: detail,
  user: user,
  origin: origin,
  at: DateTime.now(),
  duration: duration,
  success: success,
);

AppNotification _makeNotif({
  required NotificationType type,
  required String title,
  required String message,
}) => AppNotification(
  id: _uid(),
  type: type,
  title: title,
  message: message,
  at: DateTime.now(),
);

// ── Default automation rules ───────────────────────────────────────────────

final _defaultRules = [
  const AutomationRule(
    id: 'rule_water_low',
    condition: 'water_below_20',
    conditionLabel: 'Agua < 20%',
    action: 'fill_water',
    actionLabel: 'Llenar bebedero',
    enabled: true,
    requiresHITL: false,
  ),
  const AutomationRule(
    id: 'rule_motion_notify',
    condition: 'motion_detected',
    conditionLabel: 'Movimiento detectado',
    action: 'send_notification',
    actionLabel: 'Enviar notificación',
    enabled: true,
    requiresHITL: false,
  ),
  const AutomationRule(
    id: 'rule_motion_door',
    condition: 'motion_detected',
    conditionLabel: 'Movimiento detectado',
    action: 'request_door',
    actionLabel: 'Solicitar apertura de puerta',
    enabled: false,
    requiresHITL: true,
  ),
];

final _defaultSchedules = [
  AutomationSchedule(
    id: 'sched_morning',
    label: 'Apertura matutina',
    time: const TimeOfDay(hour: 7, minute: 0),
    days: [true, true, true, true, true, false, false],
    action: 'open_door',
    enabled: true,
  ),
  AutomationSchedule(
    id: 'sched_evening',
    label: 'Cierre nocturno',
    time: const TimeOfDay(hour: 19, minute: 0),
    days: [true, true, true, true, true, false, false],
    action: 'close_door',
    enabled: true,
  ),
];

// ── Default corrales ───────────────────────────────────────────────────────

final _defaultCorrales = [
  CorralInfo(
    id: 'corral_01',
    name: 'Corral Principal',
    description: 'Corral de bovinos — Zona norte',
    macAddress: 'A4:CF:12:8E:2F:01',
    ip: '192.168.1.120',
    firmware: 'v1.0.0',
    rssi: -62,
    availability: 99.8,
    connected: true,
    lastSyncAt: DateTime.now(),
    eventCount: 7,
    doors: [
      DoorDevice(
        id: 'door_01',
        name: 'Puerta Principal',
        state: DoorState.closed,
        mode: OperationMode.automatic,
        openCount: 3,
        openSeconds: 240,
        lastUser: 'Sistema',
        lastOpenedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ],
    waterers: [
      WatererDevice(
        id: 'water_01',
        name: 'Bebedero Principal',
        state: WaterState.full,
        percent: 85.0,
        capacityL: 50.0,
        dailyConsumptionL: 12.0,
        valveOpen: false,
        lastFilledAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
    sensors: [
      SensorDevice(
        id: 'sensor_01',
        name: 'Sensor PIR',
        zone: 'Entrada principal',
        detected: false,
        lastMotionTime: DateTime.now().subtract(const Duration(minutes: 8)),
        eventsToday: 7,
        sensitivity: 70,
      ),
    ],
  ),
];

// ── FarmProvider ──────────────────────────────────────────────────────────

class FarmProvider extends ChangeNotifier {
  final DateTime _startTime = DateTime.now();
  final _rng = Random();

  // Operador activo (sin flujo de inicio de sesión)
  final String _userName = 'Operador';
  String get userName => _userName;

  // Corrales list
  List<CorralInfo> _corrales = List.from(_defaultCorrales);
  String? _activeCorralId = 'corral_01';
  List<CorralInfo> get corrales => _corrales;
  CorralInfo? get activeCorral =>
      _corrales.firstWhere((c) => c.id == _activeCorralId, orElse: () => _corrales.first);

  // Automation config
  List<AutomationRule> _rules = List.from(_defaultRules);
  List<AutomationSchedule> _schedules = List.from(_defaultSchedules);
  List<AutomationRule> get rules => _rules;
  List<AutomationSchedule> get schedules => _schedules;

  // Main farm state
  FarmState _state = FarmState(
    connected: true,
    lastUpdate: DateTime.now(),
    doorState: DoorState.closed,
    doorOpenCount: 3,
    doorOpenSeconds: 240,
    doorLastUser: 'Sistema',
    doorLastOpenedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    waterState: WaterState.full,
    waterPercent: 85.0,
    waterCapacityL: 50.0,
    waterDailyConsumptionL: 12.0,
    valveOpen: false,
    waterLastFilledAt: DateTime.now().subtract(const Duration(hours: 2)),
    animalDetected: false,
    lastMotionTime: DateTime.now().subtract(const Duration(minutes: 8)),
    pirEventsToday: 7,
    alarmActive: false,
    operationMode: OperationMode.automatic,
    hitlPendingWater: false,
    voltageV: 3.28,
    esp32TempC: 41.5,
    cpuUsagePercent: 14,
    memoryUsedKb: 198,
    memoryTotalKb: 520,
    latencyMs: 18,
    wifiRssi: -62,
    notifications: [
      AppNotification(
        id: 'n1',
        type: NotificationType.motion,
        title: 'Movimiento detectado',
        message: 'Se detectó movimiento en el corral principal hace 8 minutos.',
        at: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.doorOpened,
        title: 'Puerta abierta',
        message: 'La puerta fue abierta manualmente hace 45 minutos.',
        at: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: true,
      ),
    ],
    auditLog: [
      AuditEvent(
        id: 'a1',
        type: AuditEventType.system,
        action: 'Sistema iniciado',
        detail: 'ESP32 conectado exitosamente. IP: 192.168.1.120',
        user: 'Sistema',
        origin: 'Sistema',
        at: DateTime.now().subtract(const Duration(hours: 3)),
        success: true,
      ),
      AuditEvent(
        id: 'a2',
        type: AuditEventType.door,
        action: 'Puerta abierta',
        detail: 'Apertura manual solicitada por operador',
        user: 'Operador',
        origin: 'Manual',
        at: DateTime.now().subtract(const Duration(minutes: 55)),
        duration: const Duration(minutes: 10),
        success: true,
      ),
      AuditEvent(
        id: 'a3',
        type: AuditEventType.door,
        action: 'Puerta cerrada',
        detail: 'Cierre automático por temporizador',
        user: 'Sistema',
        origin: 'Automático',
        at: DateTime.now().subtract(const Duration(minutes: 45)),
        success: true,
      ),
      AuditEvent(
        id: 'a4',
        type: AuditEventType.pir,
        action: 'Movimiento detectado',
        detail: 'Sensor PIR — Zona norte',
        user: 'Sensor',
        origin: 'Sensor',
        at: DateTime.now().subtract(const Duration(minutes: 8)),
        success: true,
      ),
      AuditEvent(
        id: 'a5',
        type: AuditEventType.water,
        action: 'Bebedero llenado',
        detail: 'Llenado automático completado (85% → 100%)',
        user: 'Sistema',
        origin: 'Automático',
        at: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(seconds: 45),
        success: true,
      ),
    ],
    events: [
      FarmEvent(id: 1, label: 'Conexión establecida con ESP32', at: DateTime.now().subtract(const Duration(hours: 3))),
      FarmEvent(id: 2, label: 'Puerta abierta manualmente', at: DateTime.now().subtract(const Duration(minutes: 55))),
      FarmEvent(id: 3, label: 'Puerta cerrada automáticamente', at: DateTime.now().subtract(const Duration(minutes: 45))),
      FarmEvent(id: 4, label: 'Movimiento detectado', at: DateTime.now().subtract(const Duration(minutes: 8))),
    ],
  );

  FarmState get state => _state;

  Timer? _sensorTimer;
  Timer? _fillTimer;
  Timer? _waterTimer;
  Timer? _telemetryTimer;

  FarmProvider() {
    _startSimulation();
  }

  void _startSimulation() {
    // PIR simulation: toggle every 8s
    _sensorTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      final detected = _rng.nextDouble() > 0.65;
      final changed = detected != _state.animalDetected;
      if (changed) {
        final now = DateTime.now();
        if (detected) {
          _addNotif(_makeNotif(
            type: NotificationType.motion,
            title: 'Movimiento detectado',
            message: 'Sensor PIR activado en ${activeCorral?.name ?? "Corral"}.',
          ));
        }
        _touch(_state.copyWith(
          animalDetected: detected,
          lastMotionTime: detected ? now : _state.lastMotionTime,
          pirEventsToday: detected ? _state.pirEventsToday + 1 : _state.pirEventsToday,
          lastUpdate: now,
        ), detected ? 'Movimiento detectado' : 'Sin movimiento',
          detected ? _makeAudit(type: AuditEventType.pir, action: 'Movimiento detectado', detail: 'Sensor PIR — Zona norte', origin: 'Sensor') : null,
        );
      }
    });

    // Water consumption: decrease by ~0.2% every 10s in auto/HITL
    _waterTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_state.waterState != WaterState.filling && _state.connected) {
        final newPct = (_state.waterPercent - 0.15).clamp(0.0, 100.0);
        var newState = _state.copyWith(waterPercent: newPct, lastUpdate: DateTime.now());

        // Auto-fill at 20% if auto mode or HITL pending approval
        if (newPct <= 20.0 && _state.waterState != WaterState.empty) {
          if (_state.operationMode == OperationMode.automatic) {
            _scheduleAutoFill();
          } else if (_state.operationMode == OperationMode.humanInTheLoop && !_state.hitlPendingWater) {
            newState = newState.copyWith(hitlPendingWater: true);
            _addNotif(_makeNotif(
              type: NotificationType.waterLow,
              title: 'Agua baja — Aprobación requerida',
              message: 'El nivel de agua está en ${newPct.toStringAsFixed(0)}%. Se requiere confirmación para llenar.',
            ));
          }
        }
        _state = newState;
        notifyListeners();
      }
    });

    // Telemetry fluctuation every 6s
    _telemetryTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _state = _state.copyWith(
        voltageV: 3.20 + _rng.nextDouble() * 0.15,
        esp32TempC: 38.0 + _rng.nextDouble() * 8.0,
        cpuUsagePercent: 10 + _rng.nextInt(20),
        memoryUsedKb: 190 + _rng.nextInt(40),
        latencyMs: 12 + _rng.nextInt(50),
        wifiRssi: -55 - _rng.nextInt(20),
      );
      notifyListeners();
    });
  }

  void _scheduleAutoFill() {
    if (_state.waterState == WaterState.filling) return;
    fillWater(user: 'Sistema', origin: 'Automático');
  }

  String get uptime {
    final diff = DateTime.now().difference(_startTime);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    final s = diff.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  // ── Corrales ──────────────────────────────────────────────────────────────

  void selectCorral(String id) {
    _activeCorralId = id;
    notifyListeners();
  }

  void addCorral(CorralInfo corral) {
    _corrales = [..._corrales, corral];
    notifyListeners();
  }

  void deleteCorral(String id) {
    _corrales = _corrales.where((c) => c.id != id).toList();
    if (_activeCorralId == id) {
      _activeCorralId = _corrales.isNotEmpty ? _corrales.first.id : null;
    }
    notifyListeners();
  }

  // ── Corral devices (Centro de Dispositivos — base para la Fase 3) ─────────

  List<DoorDevice> get activeDoors => activeCorral?.doors ?? const [];
  List<WatererDevice> get activeWaterers => activeCorral?.waterers ?? const [];
  List<SensorDevice> get activeSensors => activeCorral?.sensors ?? const [];

  void _replaceCorral(String corralId, CorralInfo Function(CorralInfo) update) {
    _corrales = _corrales.map((c) => c.id == corralId ? update(c) : c).toList();
    notifyListeners();
  }

  void addDoorDevice(String corralId, DoorDevice door) {
    _replaceCorral(corralId, (c) => c.copyWith(doors: [...c.doors, door]));
  }

  void addWatererDevice(String corralId, WatererDevice waterer) {
    _replaceCorral(corralId, (c) => c.copyWith(waterers: [...c.waterers, waterer]));
  }

  void addSensorDevice(String corralId, SensorDevice sensor) {
    _replaceCorral(corralId, (c) => c.copyWith(sensors: [...c.sensors, sensor]));
  }

  void updateDoorDevice(String corralId, String doorId, DoorDevice Function(DoorDevice) update) {
    _replaceCorral(corralId, (c) => c.copyWith(
      doors: c.doors.map((d) => d.id == doorId ? update(d) : d).toList(),
    ));
  }

  void updateWatererDevice(String corralId, String watererId, WatererDevice Function(WatererDevice) update) {
    _replaceCorral(corralId, (c) => c.copyWith(
      waterers: c.waterers.map((w) => w.id == watererId ? update(w) : w).toList(),
    ));
  }

  void updateSensorDevice(String corralId, String sensorId, SensorDevice Function(SensorDevice) update) {
    _replaceCorral(corralId, (c) => c.copyWith(
      sensors: c.sensors.map((s) => s.id == sensorId ? update(s) : s).toList(),
    ));
  }

  // ── Door Actions ──────────────────────────────────────────────────────────

  void openDoor({String user = 'Operador', String origin = 'Manual'}) {
    _touch(
      _state.copyWith(
        doorState: DoorState.open,
        doorOpenCount: _state.doorOpenCount + 1,
        doorLastUser: user,
        doorLastOpenedAt: DateTime.now(),
        lastUpdate: DateTime.now(),
      ),
      'Puerta abierta',
      _makeAudit(type: AuditEventType.door, action: 'Puerta abierta', detail: 'Apertura por $user', user: user, origin: origin),
    );
    _addNotif(_makeNotif(type: NotificationType.doorOpened, title: 'Puerta abierta', message: 'La puerta fue abierta por $user.'));
  }

  void closeDoor({String user = 'Operador', String origin = 'Manual'}) {
    final openSecs = _state.doorLastOpenedAt != null
        ? DateTime.now().difference(_state.doorLastOpenedAt!).inSeconds
        : 0;
    _touch(
      _state.copyWith(
        doorState: DoorState.closed,
        doorOpenSeconds: _state.doorOpenSeconds + openSecs,
        lastUpdate: DateTime.now(),
      ),
      'Puerta cerrada',
      _makeAudit(type: AuditEventType.door, action: 'Puerta cerrada', detail: 'Cierre por $user', user: user, origin: origin),
    );
    _addNotif(_makeNotif(type: NotificationType.doorClosed, title: 'Puerta cerrada', message: 'La puerta fue cerrada por $user.'));
  }

  // ── Water Actions ─────────────────────────────────────────────────────────

  void fillWater({String user = 'Operador', String origin = 'Manual'}) {
    _touch(
      _state.copyWith(
        waterState: WaterState.filling,
        valveOpen: true,
        hitlPendingWater: false,
        lastUpdate: DateTime.now(),
      ),
      'Bebedero llenándose',
      _makeAudit(type: AuditEventType.water, action: 'Llenado iniciado', detail: 'Válvula abierta por $user', user: user, origin: origin),
    );
    _fillTimer?.cancel();
    _fillTimer = Timer(const Duration(milliseconds: 3000), () {
      if (_state.waterState == WaterState.filling) {
        _touch(
          _state.copyWith(
            waterState: WaterState.full,
            waterPercent: 100.0,
            valveOpen: false,
            waterLastFilledAt: DateTime.now(),
            lastUpdate: DateTime.now(),
          ),
          'Bebedero lleno',
          _makeAudit(type: AuditEventType.water, action: 'Llenado completado', detail: 'Bebedero al 100%', user: 'Sistema', origin: origin),
        );
        _addNotif(_makeNotif(type: NotificationType.waterFilled, title: 'Bebedero lleno', message: 'El bebedero fue llenado exitosamente al 100%.'));
      }
    });
  }

  void emptyWater() => _touch(
    _state.copyWith(waterState: WaterState.empty, waterPercent: 0, valveOpen: false, lastUpdate: DateTime.now()),
    'Bebedero vaciado',
    _makeAudit(type: AuditEventType.water, action: 'Bebedero vaciado', detail: 'Vaciado manual', user: _userName, origin: 'Manual'),
  );

  void approveWaterFill() => fillWater(user: _userName, origin: 'HITL');

  void rejectWaterFill() {
    _state = _state.copyWith(hitlPendingWater: false);
    notifyListeners();
  }

  // ── Alarm ─────────────────────────────────────────────────────────────────

  void silenceAlarm() => _touch(
    _state.copyWith(alarmActive: false, lastUpdate: DateTime.now()),
    'Alarma silenciada',
    _makeAudit(type: AuditEventType.alarm, action: 'Alarma silenciada', detail: 'Silenciado por $_userName', user: _userName, origin: 'Manual'),
  );

  void triggerAlarm() => _touch(
    _state.copyWith(alarmActive: true, lastUpdate: DateTime.now()),
    'Alerta activada',
    _makeAudit(type: AuditEventType.alarm, action: 'Alarma activada', detail: 'Activada por operador', user: _userName, origin: 'Manual'),
  );

  // ── Mode ──────────────────────────────────────────────────────────────────

  void setMode(OperationMode mode) {
    _state = _state.copyWith(operationMode: mode, hitlPendingWater: false);
    notifyListeners();
  }

  // ── PIR Actions ───────────────────────────────────────────────────────────

  void registerIncident(String detail) {
    _touch(
      _state.copyWith(animalDetected: false, lastUpdate: DateTime.now()),
      'Incidente registrado',
      _makeAudit(type: AuditEventType.pir, action: 'Incidente registrado', detail: detail, user: _userName, origin: 'Manual'),
    );
  }

  // ── Automation ────────────────────────────────────────────────────────────

  void toggleRule(String id) {
    _rules = _rules.map((r) => r.id == id ? r.copyWith(enabled: !r.enabled) : r).toList();
    notifyListeners();
  }

  void toggleRuleHITL(String id) {
    _rules = _rules.map((r) => r.id == id ? r.copyWith(requiresHITL: !r.requiresHITL) : r).toList();
    notifyListeners();
  }

  void addRule(AutomationRule rule) {
    _rules = [..._rules, rule];
    notifyListeners();
  }

  void toggleSchedule(String id) {
    _schedules = _schedules.map((s) => s.id == id ? s.copyWith(enabled: !s.enabled) : s).toList();
    notifyListeners();
  }

  void addSchedule(AutomationSchedule schedule) {
    _schedules = [..._schedules, schedule];
    notifyListeners();
  }

  void deleteSchedule(String id) {
    _schedules = _schedules.where((s) => s.id != id).toList();
    notifyListeners();
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  void markNotifRead(String id) {
    _state = _state.copyWith(
      notifications: _state.notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
    notifyListeners();
  }

  void markAllRead() {
    _state = _state.copyWith(
      notifications: _state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
    notifyListeners();
  }

  int get unreadCount => _state.notifications.where((n) => !n.isRead).length;

  // ── Private ───────────────────────────────────────────────────────────────

  void _addNotif(AppNotification notif) {
    _state = _state.copyWith(
      notifications: [notif, ..._state.notifications].take(50).toList(),
    );
  }

  void _touch(FarmState newState, [String? eventLabel, AuditEvent? audit]) {
    List<FarmEvent> newEvents = _state.events;
    if (eventLabel != null) {
      newEvents = [_makeEvent(eventLabel), ..._state.events].take(20).toList();
    }
    List<AuditEvent> newAudit = _state.auditLog;
    if (audit != null) {
      newAudit = [audit, ..._state.auditLog].take(100).toList();
    }
    _state = newState.copyWith(events: newEvents, auditLog: newAudit);
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _fillTimer?.cancel();
    _waterTimer?.cancel();
    _telemetryTimer?.cancel();
    super.dispose();
  }
}