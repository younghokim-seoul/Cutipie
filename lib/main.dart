import 'package:cutipie/presentation/routers.dart';
import 'package:cutipie/presentation/theme/app_color.dart';
import 'package:cutipie/presentation/theme/app_theme.dart';
import 'package:cutipie/presentation/util/http/device_request.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await DeviceRequests.getFcmToken();
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
