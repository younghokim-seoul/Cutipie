import 'package:app_settings/app_settings.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cutipie/main.dart';
import 'package:cutipie/presentation/util/dialog/app_dialog.dart';
import 'package:cutipie/presentation/util/dialog/dialog_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

mixin class HomeEvent {
  Future<void> onMicBtnTapped(WidgetRef ref) async {
    Map<Permission, PermissionStatus> permissionStatus = await [
      Permission.microphone,
    ].request();

    bool allPermissionsGranted = permissionStatus.values.every((status) => status.isGranted);
  }
  //
  // void showNeedMicPermissionsDialog(Context context) {
  //   DialogService.show(
  //     context: rootNavigatorKey.currentContext!,
  //     dialog: AppDialog.dividedBtn(
  //       title: "권한 필요",
  //       subTitle: "설정에서 마이크 권한을 허용해 주세요.",
  //       leftBtnContent: "취소",
  //       showContentImg: false,
  //       rightBtnContent: "설정하기",
  //       onRightBtnClicked: () async {
  //         AutoRouter.of(rootNavigatorKey.currentContext!).maybePop();
  //         await AppSettings.openAppSettings();
  //       },
  //       onLeftBtnClicked: () {
  //         AutoRouter.of(rootNavigatorKey.currentContext!).maybePop();
  //       },
  //     ),
  //   );
  // }
}
