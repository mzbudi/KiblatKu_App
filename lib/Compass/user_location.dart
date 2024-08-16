import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class UserLocation extends StatefulWidget {
  const UserLocation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserLocationState createState() => _UserLocationState();
}

Future<String> _getUserLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  final placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  final placemark = placemarks.first;
  final locationName =
      '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';

  return locationName;
}

class _UserLocationState extends State<UserLocation> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserLocation(),
      builder: (context, AsyncSnapshot<String> positionSnapshot) {
        if (positionSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (positionSnapshot.hasError || !positionSnapshot.hasData) {
          return const Text('Lokasi Tidak Diketahui');
        } else {
          return Center(
            child: Text(
              positionSnapshot.data!,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          );
        }
      },
    );
  }
}
