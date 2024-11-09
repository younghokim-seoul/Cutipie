import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  //https://velog.io/@dyddn2015/Riverpod%EB%A1%9C-DIDependency-Injection-%EA%B5%AC%ED%98%84
  static AdHelper instance = AdHelper();

  AdManagerBannerAd? rewardAd;

  AdHelper({this.rewardAd});

  factory AdHelper.init() => instance = AdHelper(
        rewardAd: _loadBannerAd(),
      );
}

// AdManagerBannerAd 객체를 로드하는 함수
AdManagerBannerAd _loadBannerAd() {
  const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/5354046379';
  const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/5354046379';

  String adUnitId = androidBannerAdUnitId;
  if (Platform.isIOS) adUnitId = iosBannerAdUnitId;

  return AdManagerBannerAd(
    adUnitId: adUnitId,
    request: const AdManagerAdRequest(),
    sizes: [AdSize.banner],
    listener: AdManagerBannerAdListener(),
  )..load();
}

