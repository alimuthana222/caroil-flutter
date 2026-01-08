import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:oil_finder/models/oil_change_record.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize WorkManager for background tasks
    await Workmanager().initialize(_callbackDispatcher);

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  static Future<bool> requestPermissions() async {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();

    // For Android 13+, request exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    return notificationStatus.isGranted;
  }

  static Future<void> scheduleOilChangeReminder(OilChangeRecord record) async {
    if (!_initialized) await initialize();
    if (record.nextDueDate == null) return;

    final now = DateTime.now();
    final dueDate = record.nextDueDate!;

    // Schedule notification 7 days before
    final reminderDate = dueDate.subtract(Duration(days: 7));
    if (reminderDate.isAfter(now)) {
      await _scheduleNotification(
        id: record.id.hashCode,
        title: 'تذكير تغيير الزيت',
        body: 'حان الوقت لتغيير زيت ${record.vehicleMake} ${record.vehicleModel}',
        scheduledDate: reminderDate,
        payload: 'oil_change_reminder_${record.id}',
      );
    }

    // Schedule notification on due date
    if (dueDate.isAfter(now)) {
      await _scheduleNotification(
        id: record.id.hashCode + 1,
        title: 'موعد تغيير الزيت اليوم!',
        body: 'لا تنس تغيير زيت ${record.vehicleMake} ${record.vehicleModel}',
        scheduledDate: dueDate,
        payload: 'oil_change_due_${record.id}',
      );
    }

    // Schedule background check
    await _scheduleBackgroundCheck();
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'oil_change_channel',
        'تذكيرات تغيير الزيت',
        channelDescription: 'تذكيرات لتغيير زيت السيارة',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert DateTime to TZDateTime
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        payload: payload,
      );

      print('Notification scheduled for: $scheduledDate with ID: $id');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static Future<void> _scheduleBackgroundCheck() async {
    try {
      await Workmanager().registerPeriodicTask(
        'oil_change_check',
        'checkOilChangeDue',
        frequency: Duration(days: 1),
        constraints: Constraints(
          networkType: NetworkType.unmetered, // Fixed: Use 'unmetered' instead of 'not_required'
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      print('Background check scheduled');
    } catch (e) {
      print('Error scheduling background check: $e');
      // Fallback: schedule without network constraints
      try {
        await Workmanager().registerPeriodicTask(
          'oil_change_check',
          'checkOilChangeDue',
          frequency: Duration(days: 1),
        );
        print('Background check scheduled without constraints');
      } catch (e2) {
        print('Error scheduling background check without constraints: $e2');
      }
    }
  }

  static Future<void> cancelNotification(String recordId) async {
    try {
      await _notifications.cancel(recordId.hashCode);
      await _notifications.cancel(recordId.hashCode + 1);
      print('Notifications cancelled for record: $recordId');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      await Workmanager().cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'oil_change_channel',
        'تذكيرات تغيير الزيت',
        channelDescription: 'تذكيرات لتغيير زيت السيارة',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );

      print('Instant notification shown: $title');
    } catch (e) {
      print('Error showing instant notification: $e');
    }
  }

  // Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  // Test notification
  static Future<void> testNotification() async {
    await showInstantNotification(
      title: 'اختبار التنبيه',
      body: 'هذا اختبار للتأكد من عمل التنبيهات',
      payload: 'test_notification',
    );
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'checkOilChangeDue':
      // Check for overdue oil changes and send notifications
        await _checkOverdueOilChanges();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _checkOverdueOilChanges() async {
  try {
    print('Checking for overdue oil changes...');

    // This would typically fetch records from your database
    // and check for overdue items, then send notifications
    // You would need to implement this based on your database structure

    // For now, just log that the check was performed
    print('Background oil change check completed at: ${DateTime.now()}');
  } catch (e) {
    print('Error in background oil change check: $e');
  }
}