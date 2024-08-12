import 'package:flutter/material.dart';

class Donation extends StatelessWidget {
  const Donation({super.key});

  _addBtn() {
    // TBD
    print('asdl');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Traktir kopi untuk developer 😍"),
        const Text(
            "Kami menjaga agar layanan ini berguna untuk umat dan tetap bebas iklan"),
        const Text("Bisa juga support kami dengan nonton iklan dibawah! 👍"),
        ElevatedButton(
          onPressed: _addBtn,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: const Text("Tonton Iklan 🎬"),
        )
      ],
    ));
  }
}
