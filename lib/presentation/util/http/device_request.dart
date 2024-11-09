import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceRequests {
  static Future<String?> getFcmToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    Log.d("token is: $token");
    return token;
  }
}
