// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_functions.dart';

class ConnectGoCardLessPaymentGateway {
  static const GoCardLessAccountType _goCardLessAccountType =
      GoCardLessAccountType.live;

  /// BASE URLS
  // ignore: constant_identifier_names
  static const String _base_url_sandbox = 'https://api-sandbox.gocardless.com/';
  // ignore: constant_identifier_names
  static const String _base_url_live = 'https://api.gocardless.com/';

  /// TOP_SECRET_ACCESS_TOKEN
  // ignore: constant_identifier_names
  static const String _top_secret_access_token_sandbox =
      'sandbox_GlTsinKGfDDtewIqwWZJY_sMTA6eEK9kAPDUN8ZT';
  // ignore: constant_identifier_names
  static const String _top_secret_access_token_live =
      'live_CDDg_yjQZ3Mt343DnmoemFwFbXFrKlYDvWRAE96L';

  /// GoCardless-Version
  // ignore: constant_identifier_names
  static const String _goCardLess_version = '2015-07-06';

  static String get _getBaseUrl {
    switch (_goCardLessAccountType) {
      case GoCardLessAccountType.sandbox:
        return _base_url_sandbox;
      case GoCardLessAccountType.live:
        return _base_url_live;
      default:
        return '';
    }
  }

  static String get _getTopSecretAccessToken {
    switch (_goCardLessAccountType) {
      case GoCardLessAccountType.sandbox:
        return _top_secret_access_token_sandbox;
      case GoCardLessAccountType.live:
        return _top_secret_access_token_live;
      default:
        return '';
    }
  }

  static Map<String, String> get _getHeaders => <String, String>{
        'Authorization': 'Bearer $_getTopSecretAccessToken',
        'GoCardless-Version': _goCardLess_version,
        'Accept': 'application/json',
      };

  /// GET
  static Future<http.Response> getCallMethod(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    http.Response? response;
    try {
      debugPrint('getCallMethod');
      Uri uri = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        url,
        queryParameters,
      );
      debugPrint('$uri');
      response = await http.get(
        uri,
        headers: _getHeaders,
      );
    } catch (e) {
      debugPrint('getCallMethod Exception: $e');
    }
    debugPrint('response.statusCode:\t${response!.statusCode}');
    debugPrint('response.body:\t${response.body}');

    return response;
  }

  /// POST
  static Future<http.Response> postCallMethod(
    String url, {
    Map? body,
  }) async {
    http.Response? response;
    try {
      debugPrint('postCallMethod');
      Uri uri = Uri.parse(_getBaseUrl + url);
      debugPrint('url:$uri');
      if (body != null) debugPrint('body:$body');
      response = await http.post(
        uri,
        headers: <String, String>{
          ..._getHeaders,
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
        encoding: Encoding.getByName('UTF-8'),
      );
    } catch (e) {
      debugPrint('postCallMethod Exception: $e');
    }
    debugPrint('response.statusCode:\t${response!.statusCode}');
    debugPrint('response.body:\t${response.body}');
    return response;
  }

  /// PUT
  static Future<http.Response> putCallMethod(
    String url, {
    Map? body,
  }) async {
    http.Response? response;
    try {
      debugPrint('putCallMethod');
      Uri uri = Uri.parse(_getBaseUrl + url);
      debugPrint('url:$uri');
      if (body != null) debugPrint('body:$body');
      response = await http.put(
        uri,
        headers: <String, String>{
          ..._getHeaders,
          'Content-Type': 'application/json',
        },
        body: body,
        encoding: Encoding.getByName('UTF-8'),
      );
    } catch (e) {
      debugPrint('putCallMethod Exception: $e');
    }
    debugPrint('response.statusCode:\t${response!.statusCode}');
    debugPrint('response.body:\t${response.body}');
    return response;
  }
}
