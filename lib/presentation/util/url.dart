import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher_string.dart';

/// [ConvertUrl] class takes an URL string and transforms it into a format
/// suitable for the WebView. It handles the conversion for both Android and iOS platforms.
class ConvertUrl {
  late String url;
  String? appScheme;
  String? appLink;
  String? package;

  /// Constructs a [ConvertUrl] object.
  /// [getUrl] is the URL to be converted.
  ConvertUrl(String getUrl) {
    url = getUrl;

    List<String> splitUrl = url.replaceFirst(RegExp(r'://'), ' ').split(' ');
    appScheme = splitUrl[0];

    if (Platform.isAndroid) {
      if (isAppLink()) {
        if (appScheme!.contains('intent')) {
          List<String> intentUrl = splitUrl[1].split('#Intent;');
          String host = intentUrl[0];
          if (host.contains(':')) {
            host = host.replaceAll(RegExp(r':'), '%3A');
          }
          List<String> arguments = intentUrl[1].split(';');

          if (appScheme! != 'intent') {
            appScheme = appScheme!.split(':')[1];
            appLink = '${this.appScheme!}://$host';
          }
          for (var s in arguments) {
            if (s.startsWith('package')) {
              String package = s.split('=')[1];
              this.package = package;
            } else if (s.startsWith('scheme')) {
              String scheme = s.split('=')[1];
              appLink = '$scheme://$host';
              appScheme = scheme;
            }
          }
        } else {
          appLink = url;
        }
      } else {
        appLink = url;
      }
    } else if (Platform.isIOS) {
      appLink = appScheme == 'itmss' ? 'https://${splitUrl[1]}' : url;
    }
  }

  /// Returns the application link after conversion.
  /// The link is in a format suitable for the WebView.
  Future<String?> getAppLink() async {
    return appLink;
  }

  /// Returns the URL for the app market, based on the platform (Android or iOS)
  /// and the specific application scheme.
  Future<String?> getMarketUrl() async {
    if (Platform.isAndroid) {
      return 'market://details?id=${package!}';
    } else if (Platform.isIOS) {
      switch (appScheme) {
        case 'supertoss': // 토스
          return 'https://apps.apple.com/app/id839333328';
        case 'ispmobile': // ISP
          return 'https://apps.apple.com/app/id369125087';
        case 'kb-acp': // KB국민
          return 'https://apps.apple.com/app/id695436326';
        case 'liivbank': // Liiv
          return 'https://apps.apple.com/app/id1126232922';
        case 'mpocket.online.ansimclick': // 삼성
          return 'https://apps.apple.com/app/id535125356';
        case 'lottesmartpay': // 롯데 모바일
          return 'https://apps.apple.com/app/id668497947';
        case 'lotteappcard': // 롯데
          return 'https://apps.apple.com/app/id688047200';
        case 'lpayapp': // L.pay
          return 'https://apps.apple.com/app/id1036098908';
        case 'lmslpay': // 엘포인트
          return 'https://apps.apple.com/app/id473250588';
        case 'cloudpay': // 1Q페이
          return 'https://apps.apple.com/app/id847268987';
        case 'hanawalletmembers': // 하나머니
          return 'https://apps.apple.com/app/id1038288833';
        case 'hdcardappcardansimclick': // 현대
          return 'https://apps.apple.com/app/id702653088';
        case 'shinhan-sr-ansimclick': // 신한
          return 'https://apps.apple.com/app/id572462317';
        case 'wooripay': // 우리
          return 'https://apps.apple.com/app/id1201113419';
        case 'com.wooricard.wcard': // 우리WON
          return 'https://apps.apple.com/app/id1499598869';
        case 'newsmartpib': // 우리WON뱅킹
          return 'https://apps.apple.com/app/id1470181651';
        case 'nhallonepayansimclick': // NH
          return 'https://apps.apple.com/app/id1177889176';
        case 'citimobileapp': // 시티은행
          return 'https://apps.apple.com/app/id1179759666';
        case 'shinsegaeeasypayment': // SSGPAY
          return 'https://apps.apple.com/app/id666237916';
        case 'naversearchthirdlogin': // 네이버앱
          return 'https://apps.apple.com/app/id393499958';
        case 'payco': // 페이코
          return 'https://apps.apple.com/app/id924292102';
        case 'kakaotalk': // 카카오톡
          return 'https://apps.apple.com/app/id362057947';
        case 'kftc-bankpay': // 뱅크페이
          return 'https://apps.apple.com/app/id398456030';
        default:
          return url;
      }
    }
    return null;
  }

  /// Checks whether the given URL is an app link or a web link.
  /// Returns true if it's an app link, false otherwise.
  bool isAppLink() {
    String? scheme;
    try {
      scheme = Uri.parse(url).scheme;
    } catch (e) {
      scheme = appScheme;
    }
    return !['http', 'https', 'about', 'data', ''].contains(scheme);
  }

  /// Attempts to launch the application using the converted URL.
  /// If the application cannot be launched, it tries to open the application
  /// in the corresponding app market (Google Play for Android, App Store for iOS).
  Future<bool> launchApp(
      {LaunchMode mode = LaunchMode.externalApplication}) async {
    if (Platform.isAndroid) {
      try {
        return await launchUrlString((await getAppLink())!, mode: mode);
      } catch (e) {
        return await launchUrlString((await getMarketUrl())!, mode: mode);
      }
    } else if (Platform.isIOS) {
      final appLink = await getAppLink();
      if (appLink != null) {
        try {
          if (await launchUrlString(appLink)) return true;
        } catch (e) {
          // pass
        }
      }

      final marketUrl = await getMarketUrl();
      if (marketUrl != null) {
        try {
          return await launchUrlString(marketUrl);
        } catch (e) {
          // pass
        }
      }
    }
    return false;
  }
}
