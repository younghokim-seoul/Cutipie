import 'dart:io';

import 'package:cutipie/presentation/home/home_event.dart';
import 'package:cutipie/presentation/util/extension/bool_extension.dart';
import 'package:cutipie/presentation/util/recrod/record_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final recordProvider = ChangeNotifierProvider.autoDispose<RecordProvider>((ref) {
  final provider = RecordProvider();
  provider.initConfigSettings();

  ref.onDispose((){
      provider.recordController.dispose();
  });
  return provider;
});


class RecordProvider extends ChangeNotifier with HomeEvent{
  /// 음성 인식 상태 (준비, 듣는 중, 완료 , 등등)
  RecordProgressState progressState = RecordProgressState.initial;

  /// 음성 녹음 컨트롤러
  final recordController = AudioRecorder();

  /// 음성 녹음 파일이 저장되는 경로
  late String recordPath;


  ///
  /// 각종 컨트롤러 및 path 초기 설정
  ///
  Future<void> initConfigSettings() async {
    final hasPermission = await recordController.hasPermission();
    if (!hasPermission) {
      // showNeedMicPermissionsDialog();
      return;
    }

    Directory tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/myFile.m4a';
    recordPath = targetPath;

    if (await File(recordPath).exists()) {
      await File(recordPath).delete();
    }
  }

  ///
  /// 음성 인식 시작
  ///
  Future<void> startRecord(WidgetRef ref) async {
    await Future.microtask(() => _updateProgressState(RecordProgressState.loading));

    _updateProgressState(RecordProgressState.ready, resetText: true);
    await recordController.start(const RecordConfig(), path: recordPath);
    _updateProgressState(RecordProgressState.onProgress, resetText: true);
  }

  ///
  /// 음성 인식 정지
  ///
  Future<void> stopRecord(WidgetRef ref) async {
    _updateProgressState(RecordProgressState.loading);
  }

  ///
  /// 진핸 상태 변경
  ///
  void _updateProgressState(RecordProgressState state, {bool resetText = false, bool allowNotify = true}) {
    progressState = state;
    if (resetText.isTrue) {}
    if (allowNotify.isTrue) {
      notifyListeners();
    }
  }

  ///
  /// 음성 인식 결과 제출
  ///
  Future<void> submitRecognizedText(WidgetRef ref) async {
    _updateProgressState(RecordProgressState.initial);
  }
}
