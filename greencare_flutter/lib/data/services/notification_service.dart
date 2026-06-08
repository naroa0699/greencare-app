import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Servicio para manejar notificaciones locales programadas.
/// Lo dejo sencillo para el TFG: programar, cancelar y cancelar todo.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(initSettings);

    final AndroidFlutterLocalNotificationsPlugin? plugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (plugin != null) {
      await plugin.requestNotificationsPermission();
    }
  }

  Future<void> scheduleWateringNotification({
    required int id,
    required String plantName,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'watering_channel',
        'Recordatorios de riego',
        channelDescription: 'Avisos para regar tus plantas',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      '💧 ¡Hora de regar!',
      '$plantName necesita agua hoy.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Notificación programada para $plantName el $scheduledDate');
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
