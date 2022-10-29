part of app_utils.connect.hive;

class ConnectHiveNetworkData {
  ///* --------------- key --------------- *///
  static const _history = 'history';

  ///* --------------- function --------------- *///

  /// initialize
  static Future initialize() async {
    return await Hive.openBox(ConnectHive.boxNameNetworkData);
  }

  /// clear
  static get clearNetworkData async => await ConnectHive.boxNetworkData.clear();

  /// getter
  static get getHistory =>
      json.decode(json.encode(ConnectHive.boxNetworkData.get(_history)));

  /// setter
  static setHistory(input) => ConnectHive.boxNetworkData.put(_history, input);
}
