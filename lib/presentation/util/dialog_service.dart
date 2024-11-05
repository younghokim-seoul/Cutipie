import 'package:flutter/material.dart';

class DialogService {
  DialogService._();

  static void show({
    required BuildContext context,
    required Dialog dialog,
    bool? dismissible,
  }) {
    showDialog(
      barrierDismissible: dismissible ?? true,
      context: context,
      builder: (_) => dialog,
    );
  }

}
