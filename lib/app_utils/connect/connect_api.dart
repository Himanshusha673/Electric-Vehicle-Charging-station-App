import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_functions.dart';
import 'hive/connect_hive.dart';

class ConnectApi {
  // ignore: constant_identifier_names
  static const String _BASE_URL =
      'https://api.greenpointev.com/inindia.tech/public/api/'; // "https://ocpp.greenpointev.com/inindia.tech/public/api/"

  /// POST
  static Future postCallMethod(
    String url, {
    bool customUrl = false,
    Map? body,
    bool bodyBytes = false,
    Map<String, String>? headers,
  }) async {
    http.Response? response;
    try {
      debugPrint('postCallMethod');
      if (!customUrl) {
        debugPrint('url:${_BASE_URL + url}');
      }
      if (customUrl) {
        debugPrint('url:$url');
      }
      if (body != null) debugPrint('body:$body');
      response = await http.post(
        (customUrl) ? Uri.parse(url) : Uri.parse(_BASE_URL + url),
        headers: headers ??
            {
              'Content-type': 'application/json',
              if (padQuotes(ConnectHiveSessionData.getToken).isNotEmpty)
                'Authorization': 'Bearer ${ConnectHiveSessionData.getToken}',
            },
        body: json.encode(body),
      );
    } on SocketException {
      debugPrint('SocketException');
      return Future.value(null);
    } on HandshakeException {
      debugPrint('HandshakeException');
      return Future.value(null);
    } catch (e) {
      debugPrint('postCallMethod Exception: $e');
      return Future.value(null);
    }
    debugPrint('$url response.statusCode => ${response.statusCode}');
    debugPrint('$url => response.body => ${response.body}');
    if (response.statusCode == 200) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    } else if (response.statusCode == 401) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    }
    return Future.value(null);
  }

  /// GET
  static Future getCallMethod(
    String url, {
    bool customUrl = false,
    bool bodyBytes = false,
    Map<String, String>? headers,
  }) async {
    http.Response? response;
    try {
      debugPrint('getCallMethod');
      if (!customUrl) {
        debugPrint('url:${_BASE_URL + url}');
      }
      if (customUrl) {
        debugPrint('url:$url');
      }
      response = await http.get(
        (customUrl) ? Uri.parse(url) : Uri.parse(_BASE_URL + url),
        headers: headers ??
            {
              if (padQuotes(ConnectHiveSessionData.getToken).isNotEmpty)
                'Authorization': 'Bearer ${ConnectHiveSessionData.getToken}',
            },
      );
      log('API Request url:$url and Status Code is : ${response.statusCode}');
      log('API Response is : ${response.body.toString()}');
    } on SocketException {
      debugPrint('SocketException');
      return Future.value(null);
    } on HandshakeException {
      debugPrint('HandshakeException');
      return Future.value(null);
    } catch (e) {
      debugPrint('getCallMethod Exception: $e');
      return Future.value(null);
    }
    debugPrint('$url response.statusCode => ${response.statusCode}');
    debugPrint('$url => response.body => ${response.body}');
    if (response.statusCode == 200) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    } else if (response.statusCode == 401) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    }
    return Future.value(null);
  }

  /// PUT
  static Future putCallMethod(
    String url, {
    Map? body,
    bool bodyBytes = false,
    Map<String, String>? headers,
  }) async {
    http.Response? response;
    try {
      debugPrint('putCallMethod');
      debugPrint('url:${_BASE_URL + url}');
      if (body != null) debugPrint('body:$body');
      response = await http.put(
        Uri.parse(_BASE_URL + url),
        headers: headers ??
            {
              if (padQuotes(ConnectHiveSessionData.getToken).isNotEmpty)
                'Authorization': 'Bearer ${ConnectHiveSessionData.getToken}',
            },
        body: body,
      );
    } catch (e) {
      debugPrint('putCallMethod Exception: $e');
    }
    debugPrint('$url response.statusCode => ${response!.statusCode}');
    debugPrint('$url => response.body => ${response.body}');
    if (response.statusCode == 200) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    } else if (response.statusCode == 401) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    }
    return Future.value(null);
  }

  /// DELETE
  static Future deleteCallMethod(
    String url, {
    bool bodyBytes = false,
    Map<String, String>? headers,
  }) async {
    http.Response? response;
    try {
      debugPrint('deleteCallMethod');
      debugPrint('url:${_BASE_URL + url}');
      response = await http.delete(
        Uri.parse(_BASE_URL + url),
        headers: headers ??
            {
              if (padQuotes(ConnectHiveSessionData.getToken).isNotEmpty)
                'Authorization': 'Bearer ${ConnectHiveSessionData.getToken}',
            },
      );
    } catch (e) {
      debugPrint('deleteCallMethod Exception: $e');
    }
    debugPrint('$url response.statusCode => ${response!.statusCode}');
    debugPrint('$url => response.body => ${response.body}');
    if (response.statusCode == 200) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    } else if (response.statusCode == 401) {
      if (bodyBytes) {
        return response.bodyBytes;
      } else {
        return json.decode(response.body);
      }
    }
    return Future.value(null);
  }
}
