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
      // Ambil lokasi pengguna
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Tentukan koordinat berdasarkan lokasi pengguna
      final myCoordinates = Coordinates(position.latitude, position.longitude);

      // Dapatkan parameter perhitungan
      final params = CalculationMethod.muslim_world_league
          .getParameters(); // Gunakan metode MWL atau lainnya sesuai kebutuhan
      params.madhab = Madhab.shafi;

      // Ambil waktu salat hari ini
      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      // Ambil zona waktu
      final localTimeZone = DateTime.now().timeZoneName;

      // Dapatkan nama kota dan negara
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

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: Text(
                  'Jadwal Salat Hari Ini waktu $_timeZone Wilayah $_locationName',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(height: 16.0),
            _buildPrayerTimeItem('Fajr', prayerTimes.fajr),
            _buildPrayerTimeItem('Sunrise', prayerTimes.sunrise),
            _buildPrayerTimeItem('Dhuhr', prayerTimes.dhuhr),
            _buildPrayerTimeItem('Asr', prayerTimes.asr),
            _buildPrayerTimeItem('Maghrib', prayerTimes.maghrib),
            _buildPrayerTimeItem('Isha', prayerTimes.isha),
          ],
        );
      },
    );
  }

  Widget _buildPrayerTimeItem(String label, DateTime time) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Text(DateFormat.jm().format(time)),
    );
  }
}
