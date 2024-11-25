import 'package:auto_route/auto_route.dart';
import 'package:cutipie/presentation/routers.gr.dart';
import 'package:flutter/material.dart';

@AutoRouterConfig(generateForDir: ['lib/presentation'])
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        CustomRoute(
          page: SplashRoute.page,
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            return FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
              child: child,
            );
          },
          initial: true,
        ),
        CustomRoute(
          page: HomeRoute.page,
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
              child: child,
            );
          },
        ),
      ];
}
