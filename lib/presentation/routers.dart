import 'package:auto_route/auto_route.dart';
import 'package:cutipie/presentation/routers.gr.dart';

@AutoRouterConfig(generateForDir: ['lib/presentation'])
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: AdRoute.page),
      ];
}
