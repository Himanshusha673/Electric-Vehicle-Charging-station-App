part of app_utils.connect.hive;

class ConnectHiveSessionData {
  ///* --------------- key --------------- *///
  static const _token = 'token';
  static const _email = 'email';
  static const _appId = 'appId';
  static const _idTag = 'idTag';
  static const _directDebitToken = 'directDebitToken';
  static const _chargeStartTime = 'chargeStartTime';
  static const _chargeEndTime = 'chargeEndTime';
  static const _isSmartChargingEnabled = 'isSmartChargingEnabled';
  static const _directDebitDetails = 'directDebitDetails';
  static const _timeZoneData = 'timeZoneData';
  static const _isChargingStarted = 'isChargingStarted';
  static const _isChargingScheduled = 'isChargingScheduled';
  static const _chargingStartedDetail = 'chargingStartedDetails';
  static const _chargingScheduledDetail = 'chargingScheduledDetails';
  static const _cardDetails = 'cardDetails';

  ///* --------------- function --------------- *///
  /// initialize
  static Future initialize() async =>
      await Hive.openBox(ConnectHive.boxNameSessionData);

  /// clear
  static get clearSessionData async => await ConnectHive.boxSessionData.clear();

  /// watch
  static Stream<BoxEvent> get watchIsSmartChargingEnabled =>
      ConnectHive.boxSessionData.watch(key: _isSmartChargingEnabled);

  static Stream<BoxEvent> get watchIsChargingStarted =>
      ConnectHive.boxSessionData.watch(key: _isChargingStarted);

  static Stream<BoxEvent> get watchIsChargingScheduled =>
      ConnectHive.boxSessionData.watch(key: _isChargingScheduled);

  /// getter
  static String? get getToken => ConnectHive.boxSessionData.get(_token);

  static get getEmail => ConnectHive.boxSessionData.get(_email);

  static get getAppId => ConnectHive.boxSessionData.get(_appId);

  static get getIdTag => ConnectHive.boxSessionData.get(_idTag);

  static get getDirectDebitToken =>
      ConnectHive.boxSessionData.get(_directDebitToken);

  static get getChargeStartTime =>
      ConnectHive.boxSessionData.get(_chargeStartTime);

  static get getChargeEndTime => ConnectHive.boxSessionData.get(_chargeEndTime);

  static bool? get getIsSmartChargingEnabled =>
      ConnectHive.boxSessionData.get(_isSmartChargingEnabled);

  static dddm.DirectDebitDetailsModel? get getDirectDebitDetails {
    Map<String, dynamic>? _data =
        ConnectHive.boxSessionData.get(_directDebitDetails);
    return dddm.DirectDebitDetailsModel.fromJson(_data!);
  }

  static TimeZoneResponseModel? get getTimeZoneDetails {
    Map<String, dynamic>? _data =
        json.decode(json.encode(ConnectHive.boxSessionData.get(_timeZoneData)))
            as Map<String, dynamic>?;
    TimeZoneResponseModel? _timeZoneDetails;
    if (_data != null) {
      _timeZoneDetails = TimeZoneResponseModel.fromJson(_data);
    }
    return _timeZoneDetails;
  }

  static bool? get getIsChargingStarted =>
      ConnectHive.boxSessionData.get(_isChargingStarted);

  static bool? get getIsChargingScheduled =>
      ConnectHive.boxSessionData.get(_isChargingScheduled);

  static cstadm.ChargingStartedDetailsModel? get getChargingStartedDetails {
    Map<String, dynamic>? _data = json.decode(
            json.encode(ConnectHive.boxSessionData.get(_chargingStartedDetail)))
        as Map<String, dynamic>?;
    cstadm.ChargingStartedDetailsModel? _chargingStartedDetails;
    if (_data != null) {
      _chargingStartedDetails =
          cstadm.ChargingStartedDetailsModel.fromJson(_data);
    }
    return _chargingStartedDetails;
  }

  static cschdm.ChargingScheduledDetailsModel? get getChargingScheduledDetails {
    Map<String, dynamic>? _data = json.decode(json
            .encode(ConnectHive.boxSessionData.get(_chargingScheduledDetail)))
        as Map<String, dynamic>?;
    cschdm.ChargingScheduledDetailsModel? _chargingScheduledDetails;
    if (_data != null) {
      _chargingScheduledDetails =
          cschdm.ChargingScheduledDetailsModel.fromJson(_data);
    }
    return _chargingScheduledDetails;
  }

  static CardDetails? get getCardDetails {
    CardDetails? creditCard;
    print(
        "At get Card : ${ConnectHive.boxSessionData.get(_cardDetails).toString()}");
    if (ConnectHive.boxSessionData.get(_cardDetails) != null) {
      // creditCard =
      //     CardDetails.fromJson(ConnectHive.boxSessionData.get(_cardDetails));
    }
    return creditCard;
  }

  /// setter
  static setToken(input) => ConnectHive.boxSessionData.put(_token, input);

  static setEmail(input) => ConnectHive.boxSessionData.put(_email, input);

  static setAppId(input) => ConnectHive.boxSessionData.put(_appId, input);

  static setIdTag(input) => ConnectHive.boxSessionData.put(_idTag, input);

  static setDirectDebitToken(input) =>
      ConnectHive.boxSessionData.put(_directDebitToken, input);

  static setChargeStartTime(input) =>
      ConnectHive.boxSessionData.put(_chargeStartTime, input);

  static setChargeEndTime(input) =>
      ConnectHive.boxSessionData.put(_chargeEndTime, input);

  static setIsSmartChargingEnabled(bool input) =>
      ConnectHive.boxSessionData.put(_isSmartChargingEnabled, input);

  static setDirectDebitDetails(Map<String, dynamic> input) =>
      ConnectHive.boxSessionData.put(_directDebitDetails, input);

  static setIsChargingStarted(bool input) =>
      ConnectHive.boxSessionData.put(_isChargingStarted, input);

  static setIsChargingScheduled(bool input) =>
      ConnectHive.boxSessionData.put(_isChargingScheduled, input);

  static setChargingStartedDetails({
    required cstadm.ChargingStartedDetailsModel chargingStartedDetails,
  }) =>
      ConnectHive.boxSessionData
          .put(_chargingStartedDetail, chargingStartedDetails.toJson());

  static setChargingScheduledDetails({
    required cschdm.ChargingScheduledDetailsModel chargingScheduledDetails,
  }) =>
      ConnectHive.boxSessionData
          .put(_chargingScheduledDetail, chargingScheduledDetails.toJson());

  static setCardDetails({required CardDetails creditCard}) =>
      ConnectHive.boxSessionData.put(_cardDetails, creditCard.toJson());

  static setTimeZone(TimeZoneResponseModel data) {
    Map<String, dynamic> jsonData = data.toJson();
    ConnectHive.boxSessionData.put(_timeZoneData, jsonData);
  }

  /// delete
  static get deleteToken async =>
      await ConnectHive.boxSessionData.delete(_token);

  static get deleteEmail async =>
      await ConnectHive.boxSessionData.delete(_email);

  static get deleteAppId async =>
      await ConnectHive.boxSessionData.delete(_appId);

  static get deleteIdTag async =>
      await ConnectHive.boxSessionData.delete(_idTag);

  static get deleteDirectDebitToken async =>
      await ConnectHive.boxSessionData.delete(_directDebitToken);
  static get deleteTimeZone async =>
      await ConnectHive.boxSessionData.delete(_timeZoneData);

  static get deleteChargeStartTime async =>
      await ConnectHive.boxSessionData.delete(_chargeStartTime);

  static get deleteChargeEndTime async =>
      await ConnectHive.boxSessionData.delete(_chargeEndTime);

  static get deleteIsSmartChargingEnabled async =>
      await ConnectHive.boxSessionData.delete(_isSmartChargingEnabled);

  static get deleteDirectDebitDetails async =>
      await ConnectHive.boxSessionData.delete(_directDebitDetails);

  static get deleteIsChargingStarted async =>
      await ConnectHive.boxSessionData.delete(_isChargingStarted);

  static get deleteIsChargingScheduled async =>
      await ConnectHive.boxSessionData.delete(_isChargingScheduled);

  static get deleteChargingStartedDetails async =>
      await ConnectHive.boxSessionData.delete(_chargingStartedDetail);

  static get deleteChargingScheduledDetails async =>
      await ConnectHive.boxSessionData.delete(_chargingScheduledDetail);

  static get deleteCardDetails async =>
      await ConnectHive.boxSessionData.delete(_cardDetails);
}
