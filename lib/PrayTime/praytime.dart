import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView(
                  children: [
                    _buildPrayerTimeItem('Fajr', prayerTimes.fajr),
                    _buildPrayerTimeItem('Sunrise', prayerTimes.sunrise),
                    _buildPrayerTimeItem('Dhuhr', prayerTimes.dhuhr),
                    _buildPrayerTimeItem('Asr', prayerTimes.asr),
                    _buildPrayerTimeItem('Maghrib', prayerTimes.maghrib),
                    _buildPrayerTimeItem('Isha', prayerTimes.isha),
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

  Widget _buildPrayerTimeItem(String label, DateTime time) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: Text(DateFormat.jm().format(time)),
      ),
    );
  }
}
