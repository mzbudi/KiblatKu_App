import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

class Praytime extends StatefulWidget {
  const Praytime({super.key});

  @override
  _PraytimeState createState() => _PraytimeState();
}

class _PraytimeState extends State<Praytime> {
  late Future<PrayerTimes> _prayerTimesFuture;
  late String _timeZone;
  late String _locationName;

  @override
  void initState() {
    super.initState();
    _prayerTimesFuture = _fetchPrayerTimes();
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

      return prayerTimes;
    } catch (e) {
      throw e;
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
