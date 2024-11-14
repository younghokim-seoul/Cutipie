import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cutipie/presentation/util/data/share_status.dart';
import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:cutipie/presentation/util/dialog/app_dialog.dart';
import 'package:cutipie/presentation/util/dialog/dialog_service.dart';
import 'package:cutipie/presentation/util/gesture_recognizer.dart';
import 'package:cutipie/presentation/util/http/device_request.dart';
import 'package:cutipie/presentation/util/http/http_provider.dart';
import 'package:cutipie/presentation/util/purchase/purchase_provider.dart';
import 'package:cutipie/presentation/util/recrod/record_provider.dart';
import 'package:cutipie/presentation/util/url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:path_provider/path_provider.dart' as pp;

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

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  double progress = 0;

  late InAppWebViewController _webviewController;
  final Completer<void> _onPageFinishedCompleter = Completer<void>();
  var gestureRecognizer = NestedVerticalScrollGestureRecognizer();

  late RecordProvider _recordProvider;
  late PurchaseProvider _purchaseProvider;

  @override
  void initState() {
    super.initState();

    _recordProvider = ref.read(recordProvider);
    _purchaseProvider = ref.read(purchaseProvider);
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
              if (context.mounted) {
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
              RegExp regExp = RegExp("^(${prefixes.map(RegExp.escape).join('|')})");
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
                print("앱링크 : $handled");
                await appScheme.launchApp(mode: LaunchMode.externalApplication); // 앱 설치 상태에 따라 앱 실행 또는 마켓으로 이동
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            onWebViewCreated: (InAppWebViewController controller) async {
              _webviewController = controller;
              _webviewController.setSettings(
                settings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: false,
                  useShouldOverrideUrlLoading: true,
                  useHybridComposition: true,
                  javaScriptEnabled: true,
                  userAgent:
                      "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
                  resourceCustomSchemes: ['intent', 'market'],
                ),
              );
              addJavascriptChannels();
              evaluateJavascript(bridgeScript);

              if (Platform.isIOS) {
                // safari에서 히스토리가 쌓이지 않아 뒤로가기가 먹통인 현상 해결
                _webviewController.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse('about:blank'))));
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

  void addJavascriptChannels() {
    Log.d('addJavascriptChannels');

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_checkVoicePermission',
        callback: (args) async {
          Log.d("권한 체크 $args");
          Map<Permission, PermissionStatus> permissionStatus = await [
            Permission.microphone,
            Permission.speech,
          ].request();

          bool allPermissionsGranted = permissionStatus.values.every((status) => status.isGranted);
          Log.d("allPermissionsGranted... $allPermissionsGranted");
          if (allPermissionsGranted) {
            final isInitSetting = await _recordProvider.initConfigSettings();
            if (!isInitSetting) {
              showNeedMicPermissionsDialog();
              return;
            }

            _webviewController.evaluateJavascript(source: """
                      window.flutter_inappwebview.callHandler('app2web_recordPermissionResult', true,3);
                    """);

            _recordProvider.startRecord();
          } else {
            showNeedMicPermissionsDialog();
          }
        });

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_startVoiceRecording',
        callback: (args) {
          Log.d('녹음 시작!!');
          _recordProvider.startRecord();
        });

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_finishVoiceRecording',
        callback: (args) async {
          Log.d('전송.');
          await _recordProvider.stopRecord();
        });

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_requestPayment',
        callback: (args) async {
          Log.d('[인앱 결제 연동] 웹프론트 -> 앱');
          Log.d("	유저가 결제상품을 클릭 시 앱으로 해당 결제상품의 key, 회원 id 전달 $args");

          if (await _purchaseProvider.isAvailable()) {
            await _purchaseProvider.fetchUserProducts();
          } else {
            Log.d("인앱 결제 사용 불가능");
          }
        });

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_requestPayment',
        callback: (args) async {
          Log.d('[인앱 결제 연동] 웹프론트 -> 앱');
          Log.d("	유저가 결제상품을 클릭 시 앱으로 해당 결제상품의 key, 회원 id 전달 $args");

          if (await _purchaseProvider.isAvailable()) {
            await _purchaseProvider.fetchUserProducts();
          } else {
            Log.d("인앱 결제 사용 불가능");
          }
        });

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_requestPushToken',
        callback: (args) async {
          Log.d('[푸쉬 토큰] 웹프론트 -> 앱');
          Log.d("웹에서 앱으로 유저의 id 값 전달 $args");

          try {
            final httpService = ref.watch(networkProvider);
            final fcmToken = await DeviceRequests.getFcmToken();
            final response = await httpService.sendToPush(args.first, fcmToken!);
            Log.d("푸쉬 토큰 전송 성공 " + response.toString());
          } catch (e) {
            Log.d("푸쉬 토큰 전송 실패");
          }
        });

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_playAd',
        callback: (args) async {
          Log.d('[광고 연동 기능] 웹프론트 -> 앱');
          Log.d("웹에서 앱으로 유저의 id 값 전달 $args");
        });

    _webviewController.addJavaScriptHandler(
        handlerName: 'web2app_shareToSNS',
        callback: (args) async {
          Log.d('[캡쳐내용 SNS 공유기능] 웹프론트 -> 앱');
          Log.d("웹에서 기능 구현 후 파일 저장 및 파일명 앱으로 전송");

          String base64string = args[0];
          // var shareStatus = ShareStatus.fromJson(args);

          Log.d("shareStatus : $base64string");

          final name = DateTime.now().millisecondsSinceEpoch;
          final decodedBytes = base64Decode(base64string);
          Directory tempdirectory = await pp.getTemporaryDirectory();

          File file = File("${tempdirectory.path}/$name.png");
          await file.writeAsBytes(decodedBytes);
          final fileSize = await file.length();
          final filePath = file.path;

          Log.d("file size... $fileSize");
          Log.d("filePath... $filePath");

          final result = await Share.shareXFiles([XFile(filePath)], text: 'Great picture');
          Log.d('result.. ${result.status}');

          if (result.status == ShareResultStatus.success) {
            Log.d('Thank you for sharing the picture!');
            await file.delete();
          }



        });
  }

  void evaluateJavascript(String script) async {
    if (_onPageFinishedCompleter.isCompleted) {
      _webviewController.evaluateJavascript(source: script);
    } else {
      await _onPageFinishedCompleter.future.then((_) => _webviewController.evaluateJavascript(source: script) ?? '');
    }
  }

  @override
  bool get wantKeepAlive => true;
  static const bridgeScript = '';

  void showNeedMicPermissionsDialog() {
    DialogService.show(
      context: context,
      dialog: AppDialog.dividedBtn(
        title: "권한 필요",
        subTitle: "설정에서 마이크 권한을 허용해 주세요.",
        leftBtnContent: "취소",
        showContentImg: false,
        rightBtnContent: "설정하기",
        onRightBtnClicked: () async {
          AutoRouter.of(context).popForced();
          await AppSettings.openAppSettings();
        },
        onLeftBtnClicked: () {
          AutoRouter.of(context).popForced();
        },
      ),
    );
  }
}

class JavascriptChannel {
  final String name;
  final OnReceivedJSONObject onReceived;

  const JavascriptChannel({required this.name, required this.onReceived});
}

typedef OnReceivedJSONObject = void Function(Map<String, dynamic>);
