import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PraytimeService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  PraytimeService(this.flutterLocalNotificationsPlugin) {
    tz.initializeTimeZones();
  }

  Future<PrayerTimes> fetchPrayerTimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final myCoordinates = Coordinates(position.latitude, position.longitude);

      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      // Schedule notifications after fetching prayer times
      await scheduleNotifications(prayerTimes);

      return prayerTimes;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> scheduleNotifications(PrayerTimes prayerTimes) async {
    final notifications = [
      {'label': 'Subuh', 'time': prayerTimes.fajr},
      {'label': 'Terbit', 'time': prayerTimes.sunrise},
      {'label': 'Dzuhur', 'time': prayerTimes.dhuhr},
      {'label': 'Ashar', 'time': prayerTimes.asr},
      {'label': 'Maghrib', 'time': prayerTimes.maghrib},
      {'label': 'Isha', 'time': prayerTimes.isha},
    ];

    for (var i = 0; i < notifications.length; i++) {
      final notification = notifications[i];
      if (notification['label'] != 'Terbit') {
        await _scheduleNotification(notification['label'] as String,
            notification['time'] as DateTime, i);
      }
    }
  }

  Future<void> _scheduleNotification(
      String label, DateTime time, int id) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times',
      channelDescription: 'This channel is used for prayer time notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Convert DateTime to TZDateTime
    final tzTime = tz.TZDateTime.from(time, tz.local);

    const platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Waktu $label telah tiba',
      'Sekarang adalah waktu untuk $label.',
      tzTime, // Adjust to local time if needed
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
