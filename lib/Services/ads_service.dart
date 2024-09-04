import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  RewardedAd? _rewardedAd;

  void initialize() {
    MobileAds.instance.initialize();
    // Mulai memuat iklan setelah inisialisasi
    createRewardedAd();
    // createInterstitialAd();
  }

  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3903860563648690/6076312661',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Rewarded Ad failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned reward: ${reward.amount}');
        },
      );
      _rewardedAd = null;
      createRewardedAd();
    } else {
      print('Rewarded Ad belum dimuat');
    }
  }
}
