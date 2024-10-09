import 'package:flutter/material.dart';
import '../Services/ads_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart'; // Untuk iOS

class Donation extends StatefulWidget {
  const Donation({super.key});

  @override
  State<Donation> createState() => _DonationState();
}

class _DonationState extends State<Donation> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
  // product id from Google Play
  final Set<String> _productIds = {
    'jatitek_coffee',
    'jatitek_rice',
    'jatitek_burger',
    'jatitek_eskrim'
  };

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    // Mendengarkan update dari pembelian
    final purchaseUpdated = _iap.purchaseStream;
    purchaseUpdated.listen(_onPurchaseUpdated, onError: _onPurchaseError);
  }

  // Inisialisasi IAP dan ambil produk dari Google Play
  void _initializeIAP() async {
    _available = await _iap.isAvailable();
    if (_available) {
      ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);
      if (response.notFoundIDs.isEmpty) {
        setState(() {
          _products = response.productDetails;

          // Sort products based on price
          _products.sort((a, b) {
            double priceA = _extractNumericPrice(a.price);
            double priceB = _extractNumericPrice(b.price);
            return priceA.compareTo(priceB); // Sorting in ascending order
          });
        });
      }
    }
  }

  // Helper function to extract numeric value from price string
  double _extractNumericPrice(String priceString) {
    // Remove any non-numeric characters (e.g., '$' or 'Rp')
    String numericString = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0; // Convert to double
  }

  // Fungsi untuk memulai pembelian
  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Fungsi untuk menangani update pembelian
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        // Pembelian sedang diproses
      } else if (purchase.status == PurchaseStatus.purchased) {
        // Pembelian berhasil
        _iap.completePurchase(
            purchase); // Pastikan untuk menyelesaikan pembelian
      } else if (purchase.status == PurchaseStatus.error) {
        // Tangani error pembelian
      }
    }
  }

  // Fungsi untuk menangani error pembelian
  void _onPurchaseError(Object error) {
    print("Error pembelian: $error");
  }

  void _rewardedAdBtn() {
    AdService().showRewardedAd();
  }

  // Fungsi untuk mengembalikan teks berdasarkan product.id
  String _getDonationText(String productId) {
    switch (productId) {
      case 'jatitek_coffee':
        return 'Traktir Kopi ☕';
      case 'jatitek_rice':
        return 'Traktir Makan 🍚';
      case 'jatitek_burger':
        return 'Traktir Burger 🍔';
      case 'jatitek_eskrim':
        return 'Traktir Es Krim 🍨';
      default:
        return 'Dukungan';
    }
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
          const SizedBox(height: 60),
          Text(
            "Traktir Developer 😍",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          _buildDonationOptions(),
          const SizedBox(height: 24),
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

  Widget _buildDonationOptions() {
    return _products.isNotEmpty
        ? GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 2),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              var product = _products[index];
              return _buildDonationCard(product.title, product.price, product);
            },
          )
        : const Text("Loading donation options...");
  }

  Widget _buildDonationCard(
      String label, String price, ProductDetails product) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4),
          onPressed: () {
            _buyProduct(product);
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              _getDonationText(product.id),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ])),
    );
  }
}
