import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cutipie/main.dart';
import 'package:cutipie/presentation/util/app_dialog.dart';
import 'package:cutipie/presentation/util/dialog_service.dart';
import 'package:cutipie/presentation/util/gesture_recognizer.dart';
import 'package:cutipie/presentation/util/url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

final webKeyProvider = Provider((ref) => GlobalKey());

final baseUriProvider = Provider<String>((ref) {
  return "https://pay.snpay.co.kr";
});

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {


  late InAppWebViewController _webviewController;
  final Completer<void> _onPageFinishedCompleter = Completer<void>();
  var gestureRecognizer = NestedVerticalScrollGestureRecognizer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            final canGoBack = await _webviewController.canGoBack();

            if (canGoBack) {
              _webviewController.goBack();
            } else {
              if(context.mounted){
                DialogService.show(
                  context: context,
                  dialog: AppDialog.dividedBtn(
                    title: "앱 종료 알림",
                    subTitle: "앱을 종료 하시겠습니까?",
                    description: "확인을 누르면 종료됩니다.",
                    leftBtnContent: "종료",
                    rightBtnContent: "취소",
                    showContentImg: false,
                    onRightBtnClicked: () async {
                      context.router.popForced();
                    },
                    onLeftBtnClicked: () {
                      context.router.popForced();
                      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    },
                  ),
                );
              }
            }
          },
          child: InAppWebView(
            key: ref.watch(webKeyProvider),
            onLoadResourceWithCustomScheme: (controller, url) async {
              List<String> prefixes = ["intent", "market"];
              RegExp regExp =
                  RegExp("^(${prefixes.map(RegExp.escape).join('|')})");
              if (regExp.hasMatch(url.url.rawValue)) {
                await _webviewController.stopLoading();
                return null;
              } else {
                // custom scheme이 더 생기면 분기 추가해 가기
                return null;
              }
            },
            onScrollChanged: (controller, x, y) {
              gestureRecognizer.scrollY = y;
            },
            gestureRecognizers: {Factory(() => gestureRecognizer)},
            shouldOverrideUrlLoading: (controller, request) async {
              var handled = request.request.url.toString();

              print("requestUrl: $handled");

              final appScheme = ConvertUrl(handled);

              if (appScheme.isAppLink()) {
                await appScheme.launchApp(
                    mode: LaunchMode
                        .externalApplication); // 앱 설치 상태에 따라 앱 실행 또는 마켓으로 이동
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            onWebViewCreated: (InAppWebViewController controller) {
              _webviewController = controller;
              _webviewController.setSettings(
                settings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: false,
                  useShouldOverrideUrlLoading: true,
                  userAgent:
                      "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
                  resourceCustomSchemes: ['intent', 'market'],
                ),
              );
              evaluateJavascript(bridgeScript);
              if (Platform.isIOS) {
                // safari에서 히스토리가 쌓이지 않아 뒤로가기가 먹통인 현상 해결
                _webviewController.loadUrl(
                    urlRequest:
                        URLRequest(url: WebUri.uri(Uri.parse('about:blank'))));
              }

              _webviewController.loadUrl(urlRequest: URLRequest(url: WebUri(ref.watch(baseUriProvider))));
            },
            onLoadStop: (controller, url) {
              if (url.toString() == 'about:blank') {
                return;
              }
              if (!_onPageFinishedCompleter.isCompleted) {
                _onPageFinishedCompleter.complete();
              }
            },
          ),
        ),
      ),
    );
  }

  void evaluateJavascript(String script) async {
    if (_onPageFinishedCompleter.isCompleted) {
      _webviewController.evaluateJavascript(source: script);
    } else {
      await _onPageFinishedCompleter.future.then(
          (_) => _webviewController.evaluateJavascript(source: script) ?? '');
    }
  }

  @override
  bool get wantKeepAlive => true;
  static const bridgeScript = '';
}
