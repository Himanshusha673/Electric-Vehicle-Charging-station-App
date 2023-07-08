import 'dart:developer';
import '../app_utils/app_functions.dart';
import '../app_utils/connect/connect_api.dart';
import '../app_utils/connect/connect_remote.dart';

class AppApiCollection {
  /// ---------- GET ---------- ///

  static getDetails({String? email}) async {
    String url = 'getDetails';
    url += '/$email';
    var res = await ConnectApi.getCallMethod(url);
    return res;
  }

  static getHistoryDetails({String? email, int? pageIndex}) async {
    String url = 'historyDetails';
    url += '/$email';
    url += '?page=$pageIndex';
    var res = await ConnectApi.getCallMethod(url);
    return res;
  }

  static getStations() async {
    String url = 'inindiatech_stations';
    var res = await ConnectApi.getCallMethod(url);
    return res;
  }

  static getChargeBoxesByStation({
    String? stationId,
  }) async {
    String url = 'inindiatech_stations';
    url += '/$stationId';
    var res = await ConnectApi.getCallMethod(url);
    return res;
  }

  static getChargeBoxDetails({
    String? chargeBoxId,
  }) async {
    String url = 'connectorList';
    url += '/$chargeBoxId';
    var res = await ConnectApi.getCallMethod(url);
    return res;
  }

  static getDirectDebitToken({
    String? email,
  }) async {
    String url = 'ddToken';
    url += '/$email';
    var res = await ConnectApi.getCallMethod(url);
    return res;
  }

  static getTimeZoneData({
    double? latitude,
    double? longitude,
  }) async {
    // old api
    // String url = 'https://timezone.abstractapi.com/v1/current_time/?';
    log('aPI KEY IS ${AppConstants.abstractApiKey}');

    // url += 'api_key=${AppConstants.abstractApiKey}';
    // url += '&';
    // url += 'location=$latitude,$longitude';
    // var res = await ConnectApi.getCallMethod(
    //   url,
    //   headers: {},
    //   customUrl: true,
    // );

    //new api added by 4-july-2023
    String baseUrl =
        'https://api.greenpointev.com/inindiatech/v1/current_time/?location=';

    var url = baseUrl + '$latitude,$longitude';
    var res = await ConnectApi.getCallMethod(
      url,
      headers: {},
      customUrl: true,
    );

    return res;
  }

  static getCountries() async {
    String url = 'https://restcountries.eu/rest/v2/all';
    var res = await ConnectApi.getCallMethod(
      url,
      customUrl: true,
    );
    return res;
  }

  static getStates({
    String? region,
  }) async {
    String url = 'https://restcountries.eu/rest/v2/region';
    url += '/$region';
    var res = await ConnectApi.getCallMethod(
      url,
      customUrl: true,
    );
    return res;
  }

  /// ---------- POST ---------- ///

  static getChargeBoxByPostCode({String? query}) async {
    String url = 'filterzip';
    var body = {
      'zipcode': padQuotes(query),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static getDashBoard({
    String? email,
    String? date,
  }) async {
    String url = 'dashboard';
    var body = {
      'date': date,
      'e_mail': email,
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static addBankDetails({
    String? customerId,
    String? customerBankAccountId,
  }) async {
    String url = 'addBankDetails';
    var body = {
      'customer_id': padQuotes(customerId),
      'bank_account_id': padQuotes(customerBankAccountId),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static addCustomer({
    String? email,
    String? customerId,
  }) async {
    String url = 'addCustomer';
    var body = {
      'email': padQuotes(email),
      'customer_id': padQuotes(customerId),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static getHomeData() async {
    String url = 'inindiatech_homescreen';
    var body = {};
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static getGraphData({
    String? connectorId,
    String? transactionId,
  }) async {
    String url = 'startscreen';
    var body = {
      'connector_pk': connectorId,
      'transaction_id': transactionId,
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static addHistory({
    String? email,
    String? transactionId,
  }) async {
    String url = 'history';
    var body = {
      'email': padQuotes(email),
      'transaction_id': padQuotes(transactionId),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static getCost({
    String? transactionId,
  }) async {
    String url = 'cost';
    var body = {
      'transaction_id': transactionId,
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static checkValidEmail({
    String? email,
  }) async {
    String url = 'test';
    var body = {
      'e_mail': email,
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static storeOtp({
    String? email,
    String? otp,
  }) async {
    String url = 'otp';
    var body = {
      'e_mail': padQuotes(email),
      'otp': numeric(otp),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static verifyOtp({
    String? email,
    String? otp,
  }) async {
    String url = 'checkotp';
    var body = {
      'e_mail': email,
      'otp': numeric(otp),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static resetPassword({
    String? email,
    String? password,
  }) async {
    String url = 'reset';
    var body = {
      'e_mail': padQuotes(email),
      'password': padQuotes(password),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static login({
    String? email,
    String? password,
  }) async {
    String url = 'inindiatech_login';
    var body = {
      'e_mail': padQuotes(email).toLowerCase(),
      'password': padQuotes(password),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static register({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
  }) async {
    String url = 'inindiatech_register';
    var body = {
      'first_name': padQuotes(firstName),
      'last_name': padQuotes(lastName),
      'e_mail': padQuotes(email).toLowerCase(),
      'password': padQuotes(password),
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static getIdTag({
    String? appId,
  }) async {
    String url = 'id_tags';
    var body = {
      'app_id': appId,
    };
    var res = await ConnectApi.postCallMethod(url, body: body);
    return res;
  }

  static remoteStart({
    String? chargeBoxId,
    String? connectorId,
    String? idTag,
  }) async {
    String url = 'RemoteStart';
    var body = {
      'ChargeBoxId': chargeBoxId,
      'ConnectorId': connectorId,
      'IdTag': idTag,
    };
    var res = await ConnectRemote.postCallMethod(url, body: body);
    return res;
  }

  static remoteSchedule({
    String? chargeBoxId,
    String? connectorId,
    String? idTag,
    num? gmtOffset,
    dynamic chargeStartTime,
    dynamic chargeEndTime,
  }) async {
    String url = 'RemoteStart';
    var body = {
      'ChargeBoxId': chargeBoxId,
      'ConnectorId': connectorId,
      'IdTag': idTag,
      'ChargingProfile': {
        'StackLevel': 0,
        'ChargingProfilePurpose': 'TxProfile',
        'ChargingProfileKind': 'Recurring',
        'Recurrencykind': 'Daily',
        'ChargingSchedule': {
          'Duration': 86400,
          'StartSchedule': '2021-04-02T00:00:00.000Z',
          'ChargingRateUnit': 'A',
          'ChargingSchedulePeriod': [
            {
              'StartPeriod': 0,
              'Limit': 0,
            },
            {
              'StartPeriod':
                  timeToSecond(chargeStartTime) - (gmtOffset! * 3600),
              'Limit': 32,
            },
            {
              'StartPeriod': timeToSecond(chargeEndTime) - (gmtOffset * 3600),
              'Limit': 0,
            },
          ]
        }
      }
    };
    log('check1');
    var res = await ConnectRemote.postCallMethod(url, body: body);
    return res;
  }

  static remoteStop({
    String? chargeBoxId,
    String? transactionId,
  }) async {
    String url = 'RemoteStop';
    var body = {
      'ChargeBoxId': chargeBoxId,
      'TransactionId': transactionId,
    };
    var res = await ConnectRemote.postCallMethod(url, body: body);
    return res;
  }

  /// ---------- DELETE ---------- ///

  static deleteBankDetails({
    String? bankId,
  }) async {
    String url = 'deleteBankDetails';
    url += '/$bankId';
    var res = await ConnectApi.deleteCallMethod(url);
    return res;
  }
}
