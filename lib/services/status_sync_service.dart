// lib/services/status_sync_service.dart
import 'package:workmanager/workmanager.dart';
import '../services/esp32_service.dart';
import '../services/notification_service.dart';


class StatusSyncService {
  static const String taskName = "statusSync";

  // This function runs in a background isolate.
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == taskName) {
        try {
          // Simple poll of the /status endpoint.
          final status = await Esp32Service.getStatus();
          // Example: if motion detected, fire a native notification.
          if (status.animalDetected) {
            await NotificationService().showEvent(
              id: 'motion_bg_${DateTime.now().millisecondsSinceEpoch}',
              title: '🐾 Movimiento detectado',
              body: 'Se detectó movimiento en el corral.',
              highPriority: true,
              actions: const [
                NotificationAction(id: 'open_door_action', label: '🚪 Abrir puerta'),
                NotificationAction(id: 'close_door',      label: '🔒 Cerrar puerta'),
                NotificationAction(id: 'set_manual',      label: '✋ Modo manual'),
              ],
            );
          }
        } catch (_) {
          // Swallow errors – background task should not crash.
        }
        return true; // task completed successfully
      }
      return false; // unknown task
    });
  }
}
