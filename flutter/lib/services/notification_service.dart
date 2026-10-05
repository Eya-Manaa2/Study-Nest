import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(initializationSettings);

    _initialized = true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await initialize();

    final androidNotifications = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidNotifications?.requestNotificationsPermission();

    var exactAlarmsAllowed =
        await androidNotifications?.canScheduleExactNotifications() ?? false;
    if (!exactAlarmsAllowed) {
      await androidNotifications?.requestExactAlarmsPermission();
      exactAlarmsAllowed =
          await androidNotifications?.canScheduleExactNotifications() ?? false;
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminders',
          'Rappels de tâches',
          channelDescription: 'Notifications pour les deadlines de tâches',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
        androidScheduleMode: exactAlarmsAllowed
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
