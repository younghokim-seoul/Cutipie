import 'dart:convert';

import 'package:cutipie/presentation/routers.dart';
import 'package:cutipie/presentation/theme/app_color.dart';
import 'package:cutipie/presentation/theme/app_theme.dart';
import 'package:cutipie/presentation/util/ad_helper.dart';
import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:cutipie/presentation/util/is.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
const channel = AndroidNotificationChannel(
  'cutipie_importance_channel', // id
  'cutipie_app', // title
  description: 'This channel is used for important notifications.',
  // description
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

@pragma('vm:entry-point')
void onSelectNotification(NotificationResponse details) async {
  // explain: 앱 포그라운드 상황에 푸시가 온 것을 눌러 실행한 경우
  Log.d('앱 포그라운드 상황에 푸시가 온 것을 눌러 실행한 경우');
  Log.v('FirebaseMessaging onSelectNotification ');
}

Future<bool> _permissionWithNotification() async {

  if(Is.android){
    final androidInfo = await deviceInfo.androidInfo;
    if(androidInfo.version.sdkInt < 33){
      return true;
    }
  }
  Map<Permission, PermissionStatus> permissionStatus = await [Permission.notification].request();
  bool allPermissionsGranted = permissionStatus.values.every((status) => status.isGranted);
  return allPermissionsGranted;
}

Future<void> initializeNotification() async {

  if(!await _permissionWithNotification()){
    return;
  }

  final local = FlutterLocalNotificationsPlugin();
  await local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(AndroidNotificationChannel(
        channel.id,
        channel.name,
        importance: channel.importance,
      ));

  await local.initialize(
      const InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"),
          iOS: DarwinInitializationSettings()),
      onDidReceiveBackgroundNotificationResponse: onSelectNotification);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // explain: 프로세스가 살아있지 않은 상태에서 온 푸시를 통해 앱이 켜진 상황
  await FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) {
    if (message != null) {
      if (message.notification != null) {
        Log.v(
            'FirebaseMessaging.instance.getInitialMessage() title: ${message.notification!.title} body: ${message.notification!.body} data: ${message.data}');
      }
      // result = routeWithPushData(message.data);
    }
  });

  // explain: 프로세스가 살아있지만 백그라운드에 있는 상태에서 온 푸시를 통해 앱이 켜진 상황
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      Log.v(
          'FirebaseMessaging.onMessageOpenedApp title: ${message.notification!.title} body: ${message.notification!.body} data: ${message.data}');
    }
    // routeWithPushData(message.data);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // explain: 앱 켜져있는 상황에서의 수신시 노티 생성
    if (message.notification != null) {
      Log.v(
          'FirebaseMessaging.onMessage title: ${message.notification!.title} body: ${message.notification!.body} data: ${message.data}');
    }
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  initializeNotification();
  AdHelper.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: appRouter.config(),
        themeMode: ThemeMode.light,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        builder: (context, child) {
          AppColor.init(context);
          return child!;
        },
      ),
    );
  }
}
