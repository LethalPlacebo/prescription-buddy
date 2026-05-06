import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/prescription_record.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Los_Angeles'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: settings);
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> syncPrescriptionReminders(List<PrescriptionRecord> prescriptions,
      {required bool enabled}) async {
    if (!_initialized) {
      await initialize();
    }

    await _plugin.cancelAll();
    if (!enabled) {
      return;
    }

    for (final prescription in prescriptions) {
      for (final day in prescription.repeatDays) {
        final weekday = _weekdayToInt(day);
        if (weekday == null) {
          continue;
        }

        final scheduledDate = _nextInstanceOfWeekdayAndTime(
          weekday,
          prescription.reminderTime.hour,
          prescription.reminderTime.minute,
        );

        await _plugin.zonedSchedule(
          id: _notificationIdFor(prescription.id, day),
          title: prescription.title,
          body: 'Time to take ${prescription.title}.',
          scheduledDate: scheduledDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'prescription_reminders',
              'Prescription Reminders',
              channelDescription:
                  'Reminders for taking scheduled prescriptions',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  int _notificationIdFor(String prescriptionId, String day) {
    return Object.hash(prescriptionId, day) & 0x7fffffff;
  }

  int? _weekdayToInt(String day) {
    switch (day) {
      case 'Mon':
        return DateTime.monday;
      case 'Tue':
        return DateTime.tuesday;
      case 'Wed':
        return DateTime.wednesday;
      case 'Thu':
        return DateTime.thursday;
      case 'Fri':
        return DateTime.friday;
      case 'Sat':
        return DateTime.saturday;
      case 'Sun':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(
    int weekday,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
