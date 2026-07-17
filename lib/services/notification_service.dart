import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import '../services/status_sync_service.dart';
import 'package:flutter/material.dart';

// ── Background notification handler (top-level, required for release) ─────────
// Must be a top-level function annotated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  final actionId = response.actionId;
  if (actionId != null && actionId.isNotEmpty) {
    // Queue action so the main isolate can pick it up when it wakes
    NotificationService._pendingActions.add(actionId);
  }
}

class NotificationAction {
  final String id;
  final String label;
  const NotificationAction({required this.id, required this.label});
}

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Static initializer for app startup
  static Future<void> init() async {
    // Initialize notifications
    await NotificationService().initialize();
    // Initialize Workmanager
    Workmanager().initialize(StatusSyncService.callbackDispatcher);
    // Register periodic background task (e.g., every 15 minutes)
    Workmanager().registerPeriodicTask(
      "statusSyncTask",
      StatusSyncService.taskName,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }



  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectAction,
      // Handles taps on action buttons when app is in background/terminated
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );
    await _createChannels();

    // Request permission on Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _createChannels() async {
    const AndroidNotificationChannel highChannel = AndroidNotificationChannel(
      'event_high', // id
      'Eventos críticos', // name
      description: 'Canal para notificaciones críticas (heads‑up)',
      importance: Importance.high,
    );
    const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
      'event_default',
      'Información',
      description: 'Canal para notificaciones de información',
      importance: Importance.defaultImportance,
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highChannel);
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);
  }

  Future<void> showEvent({
    required String id,
    required String title,
    required String body,
    List<NotificationAction>? actions,
    bool highPriority = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      highPriority ? 'event_high' : 'event_default',
      highPriority ? 'Eventos críticos' : 'Información',
      channelDescription:
          highPriority ? 'Canal para notificaciones críticas' : 'Canal para notificaciones de información',
      importance: highPriority ? Importance.high : Importance.defaultImportance,
      priority: highPriority ? Priority.high : Priority.defaultPriority,
      ticker: title,
      actions: actions
          ?.map((a) => AndroidNotificationAction(a.id, a.label))
          .toList(),
    );

    final details = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(
      id.hashCode,
      title,
      body,
      details,
      payload: id,
    );
  }

  // Legacy static helper to maintain compatibility with existing code
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    List<NotificationAction>? actions,
    bool highPriority = false,
  }) async {
    await NotificationService().showEvent(
      id: id.toString(),
      title: title,
      body: body,
      actions: actions,
      highPriority: highPriority,
    );
  }

  static void Function(String actionId)? onActionTriggered;

  /// Called when the user taps the notification body (not an action button).
  /// Receives the payload string (e.g. 'motion_...') so the UI can navigate.
  static void Function(String payload)? onNotificationTapped;

  // Pending actions queued from background isolate
  static final List<String> _pendingActions = [];
  static final List<String> _pendingTaps = [];

  /// Call this periodically (e.g. in the polling loop) to drain actions
  /// that were tapped while the app was in the background.
  void drainPendingActions() {
    if (_pendingActions.isEmpty && _pendingTaps.isEmpty) return;

    final actions = List<String>.from(_pendingActions);
    _pendingActions.clear();
    for (final actionId in actions) {
      debugPrint('[NotificationService] draining background action: $actionId');
      onActionTriggered?.call(actionId);
    }

    final taps = List<String>.from(_pendingTaps);
    _pendingTaps.clear();
    for (final payload in taps) {
      debugPrint('[NotificationService] draining background tap: $payload');
      onNotificationTapped?.call(payload);
    }
  }

  void _onSelectAction(NotificationResponse response) {
    final actionId = response.actionId;
    if (actionId != null && actionId.isNotEmpty) {
      debugPrint('Notification action selected: $actionId');
      onActionTriggered?.call(actionId);
    } else if (response.payload != null) {
      // User tapped the notification body itself — navigate in-app
      debugPrint('Notification tapped, payload: ${response.payload}');
      final p = response.payload!;
      if (onNotificationTapped != null) {
        onNotificationTapped!(p);
      } else {
        // App was in background — queue for when it resumes
        _pendingTaps.add(p);
      }
    }
  }
}
