import 'package:cutipie/presentation/routers.dart';
import 'package:cutipie/presentation/theme/text_theme.dart';
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
          theme: ThemeData(textTheme: const CustomTextTheme()),
        ));
  }
}

