class ShareStatus {
  final String data;

  ShareStatus({
    required this.data,
  });

  static ShareStatus fromJson(params) {
    String shareData = params['data'];
    return ShareStatus(data: shareData);
  }

  @override
  String toString() {
    return 'data : $data';
  }
}
