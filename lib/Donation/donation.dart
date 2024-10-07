import 'package:flutter/material.dart';
import '../Services/ads_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Donation extends StatefulWidget {
  const Donation({super.key});

  @override
  State<Donation> createState() => _DonationState();
}

class _DonationState extends State<Donation> {
  // final InAppPurchase _iap = InAppPurchase.instance;
  // bool _available = true;
  // List<ProductDetails> _products = [];
  // final Set<String> _productIds = {
  //   'traktir_kopi',
  //   'traktir_nasi',
  //   'traktir_burger',
  //   'traktir_eskrim'
  // };

  @override
  void initState() {
    super.initState();
    // _initializeIAP();
  }

  // Inisialisasi IAP dan ambil produk dari Google Play
  // void _initializeIAP() async {
  //   _available = await _iap.isAvailable();
  //   if (_available) {
  //     ProductDetailsResponse response =
  //         await _iap.queryProductDetails(_productIds);
  //     if (response.notFoundIDs.isEmpty) {
  //       setState(() {
  //         _products = response.productDetails;
  //       });
  //     }
  //   }
  // }

  // Fungsi untuk memulai pembelian
  // void _buyProduct(ProductDetails product) {
  //   final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
  //   _iap.buyNonConsumable(
  //       purchaseParam:
  //           purchaseParam); // Menggunakan non-konsumabel untuk donasi satu kali
  // }

  void _rewardedAdBtn() {
    AdService().showRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Kami menjaga agar layanan ini bermanfaat untuk umat dan tetap bebas iklan",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 60,
          ),
          Text(
            "Traktir Developer 😍",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
              margin: const EdgeInsets.only(bottom: 28),
              height: 200,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2,
                children: [
                  _buildDonationCard('Traktir', '☕'),
                  _buildDonationCard('Traktir', '🍚'),
                  _buildDonationCard('Traktir', '🍔'),
                  _buildDonationCard('Traktir', '🍨'),
                ],
              )),
          const SizedBox(
            height: 24,
          ),
          const Text(
            "Bisa juga support kami dengan nonton iklan dibawah! 👍",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: _rewardedAdBtn,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, elevation: 8),
            child: const Text(
              "Tonton Iklan 🎬",
              style:
                  TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(String label, String icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4),
          onPressed: () {},
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Text(
              icon,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
          ])),
    );
  }
}
