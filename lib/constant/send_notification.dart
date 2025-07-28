// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:citgroupvn_car/service/api.dart';
import 'package:http/http.dart' as http;

class SendNotification {
  static var SERVER_KEY =
      "AAAA_jhoTfM:APA91bFhtbkKIcKHqrXqfSXCCEeueGYMOIVjV4aju3rzsV_Ai8pEYNpG6UemLLDxLZQzMMcujKqCshqZQsSEndAOmY_mJ7-4R4cej7Juv3QshXIR391KUpl8LjdZhptJ8WKj-4-eYDP0";

  static sendMessageNotification(String token, String title, String body,
      Map<String, dynamic>? payload) async {
    await client.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$SERVER_KEY',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': payload ?? <String, dynamic>{},
          'to': token
        },
      ),
    );
  }
}
