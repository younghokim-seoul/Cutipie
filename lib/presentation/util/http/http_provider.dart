import 'dart:convert';
import 'dart:io';

import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;


final networkProvider = Provider<HttpProvider>((ref) {
  return HttpProvider();
});

class HttpProvider {

  Future<String> sendToRecordFile(String userId, String recordPath) async {
    const url = "https://cutipieapp.com/api/today-record";

    Map<String, String> headers = {
      'Authorization': "apiKey=nCfYVzFv6vDG1DD271DCD27C198F51655xfaCYqCJ3626E8E55txU5FrXCKhZDi8Kya8s",
    };

    Map<String, String> data = {"id": userId};

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );
    request.fields.addAll(data);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('file', File(recordPath).path));

    var response = await request.send();

    Log.d("sendToRecordFile response : ${response.statusCode}");
    if (response.statusCode == 200) {
      return "Upload successful";
    } else {
      throw Exception('Failed to upload');
    }
  }


  Future<bool> sendToPush(String id, String token) async {
    const url = "https://cutipieapp.com/api/user/push-token";

    Map<String, String> headers = {
      'Authorization': "apiKey=nCfYVzFv6vDG1DD271DCD27C198F51655xfaCYqCJ3626E8E55txU5FrXCKhZDi8Kya8s",
    };


    Map<String, String> body = {
      'id': id,
      'token': token,
    };
    Uri uri = Uri.parse(url);
    final response = await http.post(uri, headers: headers, body: json.encode(body));

    Log.d("sendToPush response : ${response.statusCode}");

    return response.statusCode >= 200 && response.statusCode < 300;
  }


}