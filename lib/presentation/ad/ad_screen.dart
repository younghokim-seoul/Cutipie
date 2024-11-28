import 'package:auto_route/auto_route.dart';
import 'package:cutipie/presentation/util/ad_helper.dart';
import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:cutipie/presentation/util/is.dart';
import 'package:cutipie/presentation/widget/size_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class AdScreen extends ConsumerStatefulWidget {
  const AdScreen({super.key});

  @override
  ConsumerState createState() => _AdScreenState();
}

class _AdScreenState extends ConsumerState<AdScreen> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadFrontAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadFrontAd() {
    const String androidBannerAdUnitId =
        'ca-app-pub-7864289712585914/8620540325';
    const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/5354046379';

    String adUnitId = androidBannerAdUnitId;
    if (Is.ios) adUnitId = iosBannerAdUnitId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          Log.d('InterstitialAd loaded.');
          _interstitialAd = ad;
          _showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          Log.e('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          Log.d('Ad onAdDismissedFullScreenContent.');
          ad.dispose();
          context.router.popForced(true);
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          Log.e('Ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: SizedBox.shrink());
  }
}
