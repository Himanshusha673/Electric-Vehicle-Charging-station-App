import 'package:flutter/material.dart';

import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';

class CreateCustomerBankAccountProvider extends ChangeNotifier {
  String? accountNumberValidation;
  String? branchCodeValidation;
  String? accountHolderNameValidation;
  String? countryCodeValidation;

  List country = [];

  Future countryData({bool notify = false}) async {
    var res = await AppApiCollection.getCountries();
    if (res != null) {
      country = res;
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future createCustomerBankAccountValidation({
    required Map validationData,
    bool notify = false,
  }) async {
    Map validateError = {};
    Map? error = validationData['error'];
    List? errors = error!['errors'];
    if (errors != null && errors.isNotEmpty) {
      for (int i = 0; i < errors.length; i++) {
        String field = padQuotes(errors[i]['field']);
        String message = padQuotes(errors[i]['message']);
        if (!validateError.containsKey(field)) {
          validateError.addAll({
            field: message,
          });
        }
      }
      accountNumberValidation = validateError['account_number'];
      branchCodeValidation = validateError['branch_code'];
      accountHolderNameValidation = validateError['account_holder_name'];
      countryCodeValidation = validateError['country_code'];
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future createCustomerBankAccountValidationReset({
    bool notify = false,
  }) async {
    accountNumberValidation = '';
    branchCodeValidation = '';
    accountHolderNameValidation = '';
    countryCodeValidation = '';
    if (notify) {
      notifyListeners();
    }
  }

  clear() {
    accountNumberValidation = null;
    branchCodeValidation = null;
    accountHolderNameValidation = null;
    countryCodeValidation = null;
    country.clear();
  }
}
