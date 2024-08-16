import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import 'Compass/compass.dart';
import 'Donation/donation.dart';
import 'PrayTime/praytime.dart';
import 'ErrorWidgets/LocationError.dart';

void main() {
  runApp(const KiblatKuApp());
}

class KiblatKuApp extends StatelessWidget {
  const KiblatKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'KiblatKu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _tabIndex = 0;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  void _tabChanged(idx) {
    setState(() {
      _tabIndex = idx;
    });
  }

  Future<void> _checkAndRequestPermission() async {
    const permission = Permission.location;
    final status = await permission.status;

    if (status.isDenied) {
      final newStatus = await permission.request();
      setState(() {
        _locationPermissionGranted = newStatus.isGranted;
      });
    } else if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: IndexedStack(
          index: _tabIndex,
          children: _locationPermissionGranted
              ? const <Widget>[
                  Compass(),
                  Praytime(),
                  Donation(),
                ]
              : <Widget>[
                  LocationErrorWidget(
                    error: "Mohon nyalakan izin akses lokasi",
                    callback: _checkAndRequestPermission,
                  ),
                  LocationErrorWidget(
                    error: "Mohon nyalakan izin akses lokasi",
                    callback: _checkAndRequestPermission,
                  ),
                  const Donation()
                ]),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).canvasColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FlutterIslamicIcons.solidKaaba),
              label: 'Kiblat',
              key: Key('Qibla')),
          BottomNavigationBarItem(
              icon: Icon(FlutterIslamicIcons.solidPrayingPerson),
              label: 'Sholat',
              key: Key('Praytime')),
          BottomNavigationBarItem(
              icon: Icon(FlutterIslamicIcons.solidZakat),
              label: 'Donasi',
              key: Key('Donation'))
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        onTap: (tabIndex) => {_tabChanged(tabIndex)},
        currentIndex: _tabIndex,
      ),
    );
  }
}
