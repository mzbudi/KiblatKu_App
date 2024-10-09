import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import '../Compass/compass.dart';
import '../PrayTime/praytime.dart';
import '../Donation/donation.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GridView.count(
          mainAxisSpacing: 16,
          crossAxisCount: 4,
          childAspectRatio: 1,
          children: [
            _menuIcon(context, 'Arah Kiblat', FlutterIslamicIcons.solidQibla),
            _menuIcon(context, 'Jadwal Sholat',
                FlutterIslamicIcons.solidPrayingPerson),
            _menuIcon(context, 'Doa', FlutterIslamicIcons.solidPrayer),
            _menuIcon(context, 'Donasi', FlutterIslamicIcons.solidZakat),
            _menuIcon(context, 'Coming Soon', FlutterIslamicIcons.community),
          ]),
    );
  }

  Widget _menuIcon(BuildContext context, String title, IconData menuIcon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              if (title == 'Arah Kiblat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Compass()),
                );
              } else if (title == 'Jadwal Sholat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const Praytime()), // Halaman Praytime
                );
              } else if (title == 'Doa') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Compass()), // Halaman Doa
                );
              } else if (title == 'Donasi') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Donation()), // Halaman Donasi
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.amber,
                  border: Border.all(width: 3, color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Icon(
                menuIcon,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
        )
      ],
    );
  }
}
