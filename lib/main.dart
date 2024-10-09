import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'PrayTime/praytime_service.dart';

import 'Compass/compass.dart';
import 'Donation/donation.dart';
import 'PrayTime/praytime.dart';
import 'ErrorWidgets/LocationError.dart';
import 'Services/ads_service.dart';
import 'Menu/menu.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour == 0 || (hour == 1)) {
      try {
        var praytimeFetcher = PraytimeService(flutterLocalNotificationsPlugin);
        await praytimeFetcher.fetchPrayerTimes();
      } catch (e) {
        print('Error: $e');
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /**
   * Workmanager Initialization
   */
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  /**
   * End of Workmanager Section
   */

  /**
  * MobileAds Initialization
  */

  AdService().initialize();

  /**
   * End of MobileAds Section
   */

  runApp(const KiblatKuApp());
}

class KiblatKuApp extends StatelessWidget {
  const KiblatKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiblatKu',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Poppins'),
            bodyMedium: TextStyle(fontFamily: 'Poppins'),
            bodySmall: TextStyle(fontFamily: 'Poppins'),
          )),
      home: UpgradeAlert(
        showIgnore: false,
        showLater: false,
        child: const MyHomePage(title: 'KiblatKu'),
      ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkAndRequestPermission();
    });
    // _requestNotificationPermission();
  }

  void _tabChanged(idx) {
    setState(() {
      _tabIndex = idx;
    });
  }

  Future<void> _requestNotificationPermission() async {
    // Periksa apakah izin notifikasi telah diberikan
    if (await Permission.notification.isDenied) {
      // Minta izin jika belum diberikan
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
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

    await _requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            widget.title,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
        ),
        // body: IndexedStack(
        //     index: _tabIndex,
        //     children: _locationPermissionGranted
        //         ? const <Widget>[
        //             Compass(),
        //             Praytime(),
        //             Donation(),
        //           ]
        //         : <Widget>[
        //             LocationErrorWidget(
        //               error: "Mohon nyalakan izin akses lokasi",
        //               callback: _checkAndRequestPermission,
        //             ),
        //             LocationErrorWidget(
        //               error: "Mohon nyalakan izin akses lokasi",
        //               callback: _checkAndRequestPermission,
        //             ),
        //             const Donation()
        //           ]),
        // bottomNavigationBar: Container(
        //   padding: const EdgeInsets.only(top: 8, bottom: 8),
        //   color: Theme.of(context).colorScheme.inversePrimary,
        //   child: BottomNavigationBar(
        //     selectedItemColor: Theme.of(context).canvasColor,
        //     items: const [
        //       BottomNavigationBarItem(
        //           icon: Icon(FlutterIslamicIcons.solidKaaba),
        //           label: 'Kiblat',
        //           key: Key('Qibla')),
        //       BottomNavigationBarItem(
        //           icon: Icon(FlutterIslamicIcons.solidPrayingPerson),
        //           label: 'Sholat',
        //           key: Key('Praytime')),
        //       BottomNavigationBarItem(
        //           icon: Icon(FlutterIslamicIcons.solidZakat),
        //           label: 'Donasi',
        //           key: Key('Donation'))
        //     ],
        //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //     onTap: (tabIndex) => {_tabChanged(tabIndex)},
        //     currentIndex: _tabIndex,
        //     elevation: 0,
        //   ),
        // ),
        body: const Menu());
  }
}
