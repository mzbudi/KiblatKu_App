import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class GpsAccuracyStream {
  // Singleton pattern
  static final GpsAccuracyStream _instance = GpsAccuracyStream._internal();

  factory GpsAccuracyStream() {
    return _instance;
  }

  GpsAccuracyStream._internal() {
    _startListening();
  }

  final StreamController<double> _accuracyController =
      StreamController<double>.broadcast();

  Stream<double> get accuracyStream => _accuracyController.stream;

  void _startListening() {
    Geolocator.getPositionStream().listen((Position position) {
      _accuracyController.sink.add(position.accuracy);
    });
  }

  void dispose() {
    _accuracyController.close();
  }
}

class GpsAccuracyWidget extends StatelessWidget {
  const GpsAccuracyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: GpsAccuracyStream().accuracyStream,
      builder: (_, AsyncSnapshot<double> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.blue);
        }

        if (!snapshot.hasData) {
          return const Text("No GPS data available");
        }

        final accuracy = snapshot.data!;

        // Tentukan warna berdasarkan tingkat akurasi
        Color accuracyColor;
        String accuracyLabel;

        if (accuracy <= 10) {
          accuracyColor = Colors.green;
          accuracyLabel = "Tinggi";
        } else if (accuracy <= 50) {
          accuracyColor = Colors.orange;
          accuracyLabel = "Sedang";
        } else {
          accuracyColor = Colors.red;
          accuracyLabel = "Lemah";
        }

        return Text(
          "Akurasi GPS: $accuracyLabel",
          style: TextStyle(color: accuracyColor, fontSize: 16),
        );
      },
    );
  }
}
