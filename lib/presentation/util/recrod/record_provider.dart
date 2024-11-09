import 'dart:io';

import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:cutipie/presentation/util/extension/bool_extension.dart';
import 'package:cutipie/presentation/util/http/http_provider.dart';
import 'package:cutipie/presentation/util/recrod/record_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final recordProvider = Provider.autoDispose<RecordProvider>((ref) {
  final httpServiceProvider = ref.watch(networkProvider);
  final provider = RecordProvider(httpProvider: httpServiceProvider);

  ref.onDispose((){
      Log.d("디스포스...");
      provider.recordController.dispose();
  });
  return provider;
});


class RecordProvider {
  /// 음성 인식 상태 (준비, 듣는 중, 완료 , 등등)
  RecordProgressState progressState = RecordProgressState.initial;

  /// 음성 녹음 컨트롤러
  final recordController = AudioRecorder();

  /// 음성 녹음 파일이 저장되는 경로
  late String recordPath;

  final HttpProvider httpProvider;

  RecordProvider({required this.httpProvider});

  ///
  /// 각종 컨트롤러 및 path 초기 설정
  ///
  Future<bool> initConfigSettings() async {
    final hasPermission = await recordController.hasPermission();
    if (!hasPermission) {
      Log.d("여기서 끝이야???");
      return false;
    }


    Directory tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/myVoice.m4a';
    recordPath = targetPath;

    Log.d("initConfigSettings $recordPath");

    if (await File(recordPath).exists()) {
      await File(recordPath).delete();
    }
    return true;
  }

  ///
  /// 음성 인식 시작
  ///
  Future<void> startRecord() async {
    Log.d('startRecord');
    await Future.microtask(() => _updateProgressState(RecordProgressState.loading));
    _updateProgressState(RecordProgressState.ready, resetText: true);
    await recordController.start(const RecordConfig(), path: recordPath);
    _updateProgressState(RecordProgressState.onProgress, resetText: true);
  }

  ///
  /// 음성 인식 정지
  ///
  Future<void> stopRecord() async {
    Log.d('stopRecord');
    _updateProgressState(RecordProgressState.loading);

    recordController.cancel();
    await recordController.stop();

    _updateProgressState(RecordProgressState.recognized);
    _updateProgressState(RecordProgressState.initial);

    try{
      await httpProvider.sendToRecordFile("cm38d2n1w000auu4i92kvlvfd", recordPath);
      Log.d('Record File Upload Success...');
    }catch(e){
      Log.d('Record File Upload error $e');
    }finally{
      if (await File(recordPath).exists()) {
        await File(recordPath).delete();
      }
    }

  }

  ///
  /// 진핸 상태 변경
  ///
  void _updateProgressState(RecordProgressState state, {bool resetText = false, bool allowNotify = true}) {
    progressState = state;
    if (resetText.isTrue) {}
    if (allowNotify.isTrue) {

    }
  }

  ///
  /// 음성 인식 결과 제출
  ///
  Future<void> submitRecognizedText(WidgetRef ref) async {
    _updateProgressState(RecordProgressState.initial);
  }
}
