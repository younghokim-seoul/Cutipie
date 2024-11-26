import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routers.gr.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    routeByUserAuthAndData(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/splash_icon.png',width: 120,),
      ),
    );
  }

  Future<void> routeByUserAuthAndData(WidgetRef ref) async {
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      context.router.replace(const HomeRoute());
    }
  }
}
