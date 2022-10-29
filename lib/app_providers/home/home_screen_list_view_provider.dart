import 'package:flutter/material.dart';

import '../../app_utils/app_functions.dart';

class HomeScreenListViewProvider extends ChangeNotifier {
  List _chargeBoxList = [];
  List _filteredChargeBoxList = [];

  List get getChargeBoxList => _chargeBoxList;

  List get getFilteredChargeBoxList => _filteredChargeBoxList;

  setData({
    bool notify = false,
    required List chargeBoxList,
  }) {
    _chargeBoxList = chargeBoxList;
    _filteredChargeBoxList = _chargeBoxList;
    if (notify) {
      notifyListeners();
    }
  }

  applyFilter(String query) async {
    int _start;
    int _end;
    debugPrint('$runtimeType applyFilter: $query');
    if (_chargeBoxList.isNotEmpty) {
      _start = DateTime.now().microsecondsSinceEpoch;
      _filteredChargeBoxList = _filterChargeBoxList(query);
      _end = DateTime.now().microsecondsSinceEpoch;
      debugPrint('\ttime start:\t$_start');
      debugPrint('\ttime end:\t$_end');
      debugPrint('\ttime taken:\t${_end - _start} \n');
      notifyListeners();
    }
  }

  List _filterChargeBoxList(String query) {
    if (_chargeBoxList.any(
      (element) => (padQuotes(element['charge_box_id']).isNotEmpty &&
              (element['charge_box_id']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) ||
          (padQuotes(element['connector_description']).isNotEmpty &&
              element['connector_description']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) ||
          (padQuotes(element['street']).isNotEmpty &&
              element['street']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) ||
          (padQuotes(element['zip_code']).isNotEmpty &&
              element['zip_code']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) ||
          (padQuotes(element['city']).isNotEmpty &&
              element['city']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))),
    )) {
      return _chargeBoxList
          .where(
            (element) => (padQuotes(element['charge_box_id']).isNotEmpty &&
                    (element['charge_box_id']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (padQuotes(element['connector_description']).isNotEmpty &&
                    element['connector_description']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (padQuotes(element['street']).isNotEmpty &&
                    element['street']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (padQuotes(element['zip_code']).isNotEmpty &&
                    element['zip_code']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (padQuotes(element['city']).isNotEmpty &&
                    element['city']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()))),
          )
          .toList();
    }
    return [];
  }
}
