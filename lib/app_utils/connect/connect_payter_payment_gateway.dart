// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_functions.dart';

class ConnectPayterPaymentGateway {
  /// BASE URLS
  static const String _base_url_production = 'https://cps.mypayter.com/';
  static const String _base_url_test = 'https://cps-test.mypayter.com/';
  static const String _base_url_dev = 'https://cps-dev.mypayter.com/';

  /// Api Key
  static const String _apiKey_production = '291a60a6c1ade60293864084423ad22f';
  static const String _apiKey_test = '291a60a6c1ade60293864084423ad22f';
  static const String _apiKey_dev = '291a60a6c1ade60293864084423ad22f';

  static String get _getBaseUrl {
    switch (AppConstants.payterServersType) {
      case PayterServersType.production:
        return _base_url_production;
      case PayterServersType.test:
        return _base_url_test;
      case PayterServersType.dev:
        return _base_url_dev;
      default:
        return '';
    }
  }

  static String get _getApiKey {
    switch (AppConstants.payterServersType) {
      case PayterServersType.production:
        return _apiKey_production;
      case PayterServersType.test:
        return _apiKey_test;
      case PayterServersType.dev:
        return _apiKey_dev;
      default:
        return '';
    }
  }

  static Map<String, String> get _getHeaders => <String, String>{
        'Authorization': 'CPS apikey="$_getApiKey"',
        'Content-Type': 'application/json'
      };

  /// ### Get info for terminal
  static Future<Map<String, dynamic>?> getTerminalInfo({
    required String serialNumber,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{};
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber',
        _queryParameters,
      );
      debugPrint('$url');
      var response = await http.get(
        url,
        headers: _getHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### List all terminals
  static Future<Map<String, dynamic>?> getAllTerminals() async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{};
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals',
        _queryParameters,
      );
      debugPrint('$url');
      var response = await http.get(
        url,
        headers: _getHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Start reading cards, the optional webhook will be notified when card read completes
  static Future<Map<String, dynamic>?> startReadingCard({
    required String serialNumber,

    /// Amount to authorize, this is only used if authorize is called after card read
    required int authorizedAmount,
    String? callbackUrl,

    /// Message to show when requesting card
    String? uiMessage,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{
        'authorizedAmount': authorizedAmount,
        'callbackUrl': callbackUrl,
        'uiMessage': uiMessage,
      };
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/start',
        _queryParameters,
      );
      Map<String, dynamic> _body = <String, dynamic>{};
      debugPrint('$url');
      var response = await http.post(
        url,
        headers: _getHeaders,
        body: _body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Get currently active card
  static Future<Map<String, dynamic>?> getCurrentlyActiveCard({
    required String serialNumber,

    /// Time to wait for card to be read (seconds)
    int? waitTime,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{
        'waitTime': waitTime,
      };
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/card',
        _queryParameters,
      );
      debugPrint('$url');
      var response = await http.get(
        url,
        headers: _getHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Stop reading cards, this can be used while waitinf for a card or once a card has been read to return to idle
  static Future<Map<String, dynamic>?> stopReadingCard({
    required String serialNumber,

    /// Message to show when stopping card read
    String? uiMessage,

    /// Time to display ui message (seconds)
    int? uiMessageTimeout,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{
        'uiMessage': uiMessage,
        'uiMessageTimeout': uiMessageTimeout,
      };
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/stop',
        _queryParameters,
      );
      Map<String, dynamic> _body = <String, dynamic>{};
      debugPrint('$url');
      var response = await http.post(
        url,
        headers: _getHeaders,
        body: _body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Get a specific session
  static Future<Map<String, dynamic>?> getSpecificSession({
    required String serialNumber,
    required String sessionId,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{};
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/sessions/$sessionId',
        _queryParameters,
      );
      debugPrint('$url');
      var response = await http.get(
        url,
        headers: _getHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Return all sessions for a terminal
  static Future<Map<String, dynamic>?> getAllSession({
    required String serialNumber,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{};
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/sessions',
        _queryParameters,
      );
      debugPrint('$url');
      var response = await http.get(
        url,
        headers: _getHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Authorize a transaction on the currently active card, the returned session can later be commited or cancelled
  static Future<Map<String, dynamic>?> authorizeTransaction({
    required String serialNumber,

    /// Message to show once authorize complete
    String? uiMessage,

    /// Time to display ui message (seconds)
    int? uiMessageTimeout,
    List<String>? receiptLine,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{
        'uiMessage': uiMessage,
        'uiMessageTimeout': receiptLine,
        'receiptLine': receiptLine,
      };
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/authorize',
        _queryParameters,
      );
      Map<String, dynamic> _body = <String, dynamic>{};
      debugPrint('$url');
      var response = await http.post(
        url,
        headers: _getHeaders,
        body: _body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Commit a session with a final amount, after this the session is complete an the same card can start a new session
  static Future<Map<String, dynamic>?> commitSession({
    required String serialNumber,
    required String sessionId,

    /// Final amount to commit the transaction
    required int commitAmount,

    /// Message to show while completing
    String? uiMessage,

    /// Time to display ui message (seconds)
    int? uiMessageTimeout,

    /// Extra line on receipt
    List<String>? receiptLine,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{
        'commitAmount': commitAmount,
        'uiMessage': uiMessage,
        'uiMessageTimeout': uiMessageTimeout,
        'receiptLine': receiptLine,
      };
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/sessions/$sessionId/commit',
        _queryParameters,
      );
      Map<String, dynamic> _body = <String, dynamic>{};
      debugPrint('$url');
      var response = await http.post(
        url,
        headers: _getHeaders,
        body: _body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }

  /// ### Cancel a session, after this the session is complete an the same card can start a new session
  static Future<Map<String, dynamic>?> cancelSession({
    required String serialNumber,
    required String sessionId,

    /// Message to show while completing
    String? uiMessage,

    /// Time to display ui message (seconds)
    int? uiMessageTimeout,

    /// Extra line on receipt
    List<String>? receiptLine,
  }) async {
    try {
      Map<String, dynamic>? _queryParameters = <String, dynamic>{
        'uiMessage': uiMessage,
        'uiMessageTimeout': uiMessageTimeout,
        'receiptLine': receiptLine,
      };
      Uri url = Uri.https(
        getAuthorityFromUrl(_getBaseUrl),
        'terminals/$serialNumber/sessions/$sessionId/cancel',
        _queryParameters,
      );
      Map<String, dynamic> _body = <String, dynamic>{};
      debugPrint('$url');
      var response = await http.post(
        url,
        headers: _getHeaders,
        body: _body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }
}
