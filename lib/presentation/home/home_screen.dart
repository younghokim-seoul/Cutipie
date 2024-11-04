import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
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
  return "https://cutipieapp.com";
});

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  double progress = 0;

  late InAppWebViewController _webviewController;
  final Completer<void> _onPageFinishedCompleter = Completer<void>();
  var gestureRecognizer = NestedVerticalScrollGestureRecognizer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            final canGoBack = await _webviewController.canGoBack();

            if (canGoBack) {
              _webviewController.goBack();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('앱 종료'),
                  content: Text('앱이 종료됩니다.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('아니오'),
                    ),
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: Text('예'),
                    ),
                  ],
                ),
              );
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
            initialUrlRequest:
                URLRequest(url: WebUri(ref.watch(baseUriProvider))),
            shouldOverrideUrlLoading: (controller, request) async {
              var handled = request.request.url.toString();

              print("requestUrl: $handled");

              final appScheme = ConvertUrl(handled);

              if (appScheme.isAppLink()) {
                print("씨발 앱링크 : $handled");
                await appScheme.launchApp(
                    mode: LaunchMode.externalApplication); // 앱 설치 상태에 따라 앱 실행 또는 마켓으로 이동
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
                  useHybridComposition: true,
                  userAgent: "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
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
