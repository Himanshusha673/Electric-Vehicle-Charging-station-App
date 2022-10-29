import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectRemote {
  // ignore: constant_identifier_names
  static const String _BASE_URL =
      'https://api.greenpointev.com:8443/mobile/'; //"https://ocpp.greenpointev.com:8443/mobile/" // "http://api.greenpointev.com:8080/mobile/",
  /// POST
  static Future postCallMethod(
    String url, {
    Map? body,
  }) async {
    http.Response? response;
    try {
      debugPrint('postCallMethod');
      debugPrint('url:${_BASE_URL + url}');
      if (body != null) debugPrint('body:$body');
      response = await http.post(
        Uri.parse(_BASE_URL + url),
        headers: {
          'Content-type': 'application/json',
        },
        body: json.encode(body),
      );
    } catch (e) {
      debugPrint('postCallMethod Exception: $e');
    }
    debugPrint('$url response.statusCode => ${response!.statusCode}');
    debugPrint('$url => response.body => ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      return json.decode(response.body);
    }
    return Future.value(null);
  }
}
