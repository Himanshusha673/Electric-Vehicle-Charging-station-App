import 'dart:developer';

import 'package:flutter/material.dart';

import '../../app_utils/app_functions.dart';

class HomeScreenListViewProvider extends ChangeNotifier {
  List _chargeBoxList = [];
  List _filteredChargeBoxList = [];
  List _paginatedList = [];

  List get getChargeBoxList => _chargeBoxList;

  List get getFilteredChargeBoxList => _filteredChargeBoxList;

  List get getPaginatedList => _paginatedList;

  int currentPage = 1; // Track the current page
  int limit = 20; // Items per page
  bool isLoading = false; //

  setIsLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  setData({
    bool notify = false,
    required List chargeBoxList,
  }) {
    _chargeBoxList = chargeBoxList;
    _filteredChargeBoxList = _chargeBoxList;
    _paginatedList = _filteredChargeBoxList.sublist(0, 20);
    if (notify) {
      notifyListeners();
    }
  }

  setPaginatedListInitial() {
    _paginatedList = _filteredChargeBoxList.sublist(0, 20);
    notifyListeners();
  }

  applyFilter(String query) async {
    int _start;
    int _end;
    debugPrint('$runtimeType applyFilter: $query');
    if (_chargeBoxList.isNotEmpty) {
      _start = DateTime.now().microsecondsSinceEpoch;
      _filteredChargeBoxList = _filterChargeBoxList(query);
      _paginatedList = _filterChargeBoxList(query);
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

  void loadMoreData() async {
    if (!isLoading) {
      isLoading = true;
      notifyListeners();

      // Fetch the next page of data
      List newData = await _fetchNextPageData();

      // Append the new data to the existing list
      _paginatedList.addAll(newData);
      notifyListeners();
      log('new item added Index of _paginatedlist is ${_paginatedList.length}');

      // Increment the current page by 1 since we're loading 20 items
      currentPage++;

      // Stop loading
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List> _fetchNextPageData() async {
    int startIndex = (currentPage - 1) * limit;
    int endIndex = startIndex + limit;

    if (endIndex > _chargeBoxList.length) {
      endIndex = _chargeBoxList.length;
    }

    // // Simulate a delay of 2 seconds to simulate an asynchronous operation
    await Future.delayed(Duration(seconds: 2));

    if (startIndex >= endIndex) {
      // Return an empty list if there are no more items to fetch
      return [];
    }

    return _chargeBoxList.sublist(startIndex, endIndex);
  }
}
