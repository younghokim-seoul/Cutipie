// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:cutipie/presentation/ad/ad_screen.dart' as _i1;
import 'package:cutipie/presentation/home/home_screen.dart' as _i2;

/// generated route for
/// [_i1.AdScreen]
class AdRoute extends _i3.PageRouteInfo<void> {
  const AdRoute({List<_i3.PageRouteInfo>? children})
      : super(
          AdRoute.name,
          initialChildren: children,
        );

  static const String name = 'AdRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.AdScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i3.PageRouteInfo<void> {
  const HomeRoute({List<_i3.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}
