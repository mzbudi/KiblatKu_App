import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';

import 'praytime_service.dart';

class Praytime extends StatefulWidget {
  const Praytime({super.key});

  @override
  _PraytimeState createState() => _PraytimeState();
}

class _PraytimeState extends State<Praytime> {
  late Future<PrayerTimes> _prayerTimesFuture;
  late PraytimeService _praytimeService;
  late String? _timeZone;
  late String? _locationName;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    _praytimeService = PraytimeService(flutterLocalNotificationsPlugin);
    _prayerTimesFuture = _praytimeService.fetchPrayerTimes();
    _fetchLocationAndTimeZone();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    // Periksa dan minta izin notifikasi dan alarm yang tepat
    final notificationPermission = await Permission.notification.request();
    final alarmPermission = await Permission.scheduleExactAlarm.request();

    if (notificationPermission.isGranted && alarmPermission.isGranted) {
      _initializeWorkmanager(); // Inisialisasi dan daftarkan Workmanager jika izin diberikan
    }
  }

  void _initializeWorkmanager() {
    Workmanager().registerPeriodicTask('praytime-scheduler', 'pray-schedule',
        frequency: const Duration(hours: 1),
        initialDelay: const Duration(seconds: 10));
  }

  Future<void> _fetchLocationAndTimeZone() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final localTimeZone = DateTime.now().timeZoneName;

    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemark = placemarks.first;
    final locationName = '${placemark.locality}, ${placemark.country}';

    setState(() {
      _timeZone = localTimeZone;
      _locationName = locationName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PrayerTimes>(
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
          final displayTimeZone = _timeZone ?? 'Loading...';
          final displayLocationName = _locationName ?? 'Loading...';

          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Center(
                    child: Text(
                      'Jadwal Salat Hari Ini',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Zona Waktu : $displayTimeZone',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Lokasi : $displayLocationName',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ],
                          ),
                        ]),
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
                          'Subuh',
                          prayerTimes.fajr,
                          const Icon(
                            FlutterIslamicIcons.solidLantern,
                            color: Color.fromARGB(255, 249, 210, 119),
                          )),
                      _buildPrayerTimeItem(
                          'Terbit',
                          prayerTimes.sunrise,
                          const Icon(
                            Icons.wb_sunny,
                            color: Color.fromARGB(255, 252, 236, 93),
                          )),
                      _buildPrayerTimeItem(
                          'Dzuhur',
                          prayerTimes.dhuhr,
                          const Icon(
                            Icons.sunny,
                            color: Color.fromARGB(255, 251, 201, 2),
                          )),
                      _buildPrayerTimeItem(
                          'Ashar',
                          prayerTimes.asr,
                          const Icon(Icons.sunny_snowing,
                              color: Colors.orange)),
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
                  child: const Column(
                    children: [
                      Text(
                        '*Penentapan Waktu Shubuh	: 20.0°. Kemiringan Matahari',
                        style: TextStyle(fontFamily: 'Poppins'),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '*Penetapan Waktu Isya	: 18.0°. Kemiringan Matahari',
                        style: TextStyle(fontFamily: 'Poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
