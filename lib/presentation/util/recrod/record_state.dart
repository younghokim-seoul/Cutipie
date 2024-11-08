import 'package:flutter/material.dart';

enum RecordProgressState {
  initial(Colors.white), // 음성 인식을 시작할 준비가 된 상태
  ready(Color(0xFF3446EA)), // 음성 인
  onProgress(Color(0xFF3446EA)), // 음성 인식 중인 상태
  loading(Color(0xFF3446EA)), // 음성 인식 중인 상태
  recognized(Colors.white), // 음성 인식 후 텍스트가 처리된 상태
  errorOccured(Colors.red); //  오류 발생

  final Color? color;

  const RecordProgressState(this.color);

  bool get isInitial => this == initial;

  bool get isReady => this == ready;

  bool get isOnProgress => this == onProgress;

  bool get isRecognized => this == recognized;

  bool get isErrorOccured => this == errorOccured;

  bool get isLoadingResult => this == loading;
}
