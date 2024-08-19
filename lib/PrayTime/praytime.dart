import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';

class Praytime extends StatefulWidget {
  const Praytime({super.key});

  @override
  _PraytimeState createState() => _PraytimeState();
}

class _PraytimeState extends State<Praytime> {
  late Future<PrayerTimes> _prayerTimesFuture;
  late String _timeZone;
  late String _locationName;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @pragma(
      'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        _fetchPrayerTimes();
      } catch (e) {
        throw Exception(e);
      }
      return Future.value(true);
    });
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _prayerTimesFuture = _fetchPrayerTimes();
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager().registerPeriodicTask('praytime-scheduler', 'pray-schedule',
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(seconds: 10));

    // Panggil fungsi pengujian
    _requestNotificationPermission();
    // _testNotification();
  }

  Future<void> _requestNotificationPermission() async {
    // Periksa apakah izin notifikasi telah diberikan
    if (await Permission.notification.isDenied) {
      // Minta izin jika belum diberikan
      await Permission.notification.request();
    }
  }

  Future<void> _scheduleNotifications(PrayerTimes prayerTimes) async {
    final notifications = [
      {'label': 'Fajr', 'time': prayerTimes.fajr},
      {'label': 'Sunrise', 'time': prayerTimes.sunrise},
      {'label': 'Dhuhr', 'time': prayerTimes.dhuhr},
      {'label': 'Asr', 'time': prayerTimes.asr},
      {'label': 'Maghrib', 'time': prayerTimes.maghrib},
      {'label': 'Isha', 'time': prayerTimes.isha},
    ];

    for (var i = 0; i < notifications.length; i++) {
      final notification = notifications[i];
      await _scheduleNotification(
          notification['label'] as String, notification['time'] as DateTime, i);
    }
  }

  // Future<void> _testNotification() async {
  //   try {
  //     print("Oke");
  //     const androidDetails = AndroidNotificationDetails(
  //       'test_channel',
  //       'Test Notifications',
  //       channelDescription: 'This channel is used for testing notifications.',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //     );

  //     const platformDetails = NotificationDetails(android: androidDetails);

  //     // Mengatur waktu notifikasi dalam beberapa detik dari sekarang
  //     final scheduledTime = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'))
  //         .add(const Duration(seconds: 5));

  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //       999, // ID untuk notifikasi ini, bisa angka unik
  //       'Test Notifikasi',
  //       'Ini adalah notifikasi tes untuk memastikan fungsionalitas.',
  //       scheduledTime,
  //       platformDetails,
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.dateAndTime,
  //     );
  //   } catch (e) {
  //     print(Exception(e));
  //   }
  // }

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
    print(tzTime);
    print('tzTime');

    final newTz = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    print(newTz);
    print('newtz');

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

  Future<PrayerTimes> _fetchPrayerTimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final myCoordinates = Coordinates(position.latitude, position.longitude);

      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      final localTimeZone = DateTime.now().timeZoneName;

      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final placemark = placemarks.first;
      final locationName = '${placemark.locality}, ${placemark.country}';

      setState(() {
        _timeZone = localTimeZone;
        _locationName = locationName;
      });

      // Schedule notifications after fetching prayer times
      await _scheduleNotifications(prayerTimes);

      return prayerTimes;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrayerTimes>(
      future: _prayerTimesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final prayerTimes = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    'Jadwal Salat Hari Ini waktu $_timeZone Wilayah $_locationName',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    _buildPrayerTimeItem(
                        'Fajr',
                        prayerTimes.fajr,
                        const Icon(
                          FlutterIslamicIcons.solidLantern,
                          color: Color.fromARGB(255, 249, 210, 119),
                        )),
                    _buildPrayerTimeItem(
                        'Sunrise',
                        prayerTimes.sunrise,
                        const Icon(
                          Icons.wb_sunny,
                          color: Color.fromARGB(255, 252, 236, 93),
                        )),
                    _buildPrayerTimeItem(
                        'Dhuhr',
                        prayerTimes.dhuhr,
                        const Icon(
                          Icons.sunny,
                          color: Color.fromARGB(255, 251, 201, 2),
                        )),
                    _buildPrayerTimeItem('Asr', prayerTimes.asr,
                        const Icon(Icons.sunny_snowing, color: Colors.orange)),
                    _buildPrayerTimeItem(
                        'Maghrib',
                        prayerTimes.maghrib,
                        const Icon(
                          Icons.brightness_6,
                          color: Color.fromARGB(255, 224, 137, 5),
                        )),
                    _buildPrayerTimeItem(
                        'Isha',
                        prayerTimes.isha,
                        const Icon(Icons.mode_night,
                            color: Color.fromARGB(255, 243, 236, 181))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    '*Perhitungan waktu salat diambil dari Muslim World League - Mecca',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // child: ElevatedButton(
                  //   onPressed: _testNotification,
                  //   child: Text('Test Notifikasi'),
                  // ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimeItem(String label, DateTime time, Icon icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Stack(children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              DateFormat.jm().format(time),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Icon(icon.icon, size: 40, color: icon.color),
        ),
      ]),
    );
  }
}
