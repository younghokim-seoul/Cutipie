
import 'package:cutipie/presentation/theme/app_color.dart';
import 'package:cutipie/presentation/theme/filled_button_theme.dart';
import 'package:cutipie/presentation/theme/input_decoration_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'outlined_button_theme.dart';



class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColor().brand3,
    primarySwatch: Colors.blue,
    splashFactory: NoSplash.splashFactory,
    textTheme: ThemeData().textTheme.apply(
          fontFamily: 'pretendard',
          bodyColor: AppColor().black,
          displayColor: AppColor().black,
        ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: const Color(0xFFC7CCF8),
      cursorColor: AppColor().brand2,
      selectionHandleColor: AppColor().brand2,
    ),
    progressIndicatorTheme:
        ProgressIndicatorThemeData(color: AppColor().brand2),
    filledButtonTheme: CustomFilledButtonTheme.light,
    outlinedButtonTheme: CustomOutlinedButtonTheme.light,
    inputDecorationTheme: CustomInputDecorationTheme.light,
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      primaryColor: AppColor().blue2,
    ),
    // 플랫폼별 라우팅 애니메이션 속성
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      },
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppColor(),
    ],
  );
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: ThemeData().textTheme.apply(
          fontFamily: 'pretendard',
          bodyColor: AppColor().black,
          displayColor: AppColor().black,
        ),
    extensions: <ThemeExtension<dynamic>>[
      AppColor.dark(),
    ],
  );
}
