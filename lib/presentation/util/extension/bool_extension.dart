extension BoolExtension on bool {
  bool get isTrue => this == true;

  bool get isFalse => this == false;
}

bool hasValue<T>(T value) {
  return !(value == null ||
      ((value is String && (value as String).isEmpty) ||
          (value is List && (value as List).isEmpty) ||
          (value is Map && (value as Map).isEmpty)));
}
