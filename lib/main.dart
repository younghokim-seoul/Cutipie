import 'package:cutipie/presentation/routers.dart';
import 'package:cutipie/presentation/theme/app_color.dart';
import 'package:cutipie/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
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