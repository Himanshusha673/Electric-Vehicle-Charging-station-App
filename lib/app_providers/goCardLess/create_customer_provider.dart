import 'package:flutter/material.dart';

import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';

class CreateCustomerProvider extends ChangeNotifier {
  String? emailValidation;
  String? firstNameValidation;
  String? lastNameValidation;
  String? companyNameValidation;
  String? baseValidation;
  String? addressLine1Validation;
  String? addressLine2Validation;
  String? addressLine3Validation;
  String? cityValidation;
  String? postCodeValidation;
  String? countryCodeValidation;
  String? stateValidation;

  List country = [];
  List state = [];

  Future countryData({bool notify = false}) async {
    var res = await AppApiCollection.getCountries();
    if (res != null) {
      country = res;
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future stateData({
    required String region,
    bool notify = false,
  }) async {
    var res = await AppApiCollection.getStates(
      region: region,
    );
    if (res != null) {
      state = res;
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future createCustomerValidation({
    required Map validationData,
    bool notify = false,
  }) async {
    Map validateError = {};
    Map error = validationData['error'];
    List? errors = error['errors'];
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
      emailValidation = validateError['email'];
      firstNameValidation = validateError['given_name'];
      lastNameValidation = validateError['family_name'];
      companyNameValidation = validateError['company_name'];
      baseValidation = validateError['base'];
      addressLine1Validation = validateError['address_line1'];
      addressLine2Validation = validateError['address_line2'];
      cityValidation = validateError['city'];
      postCodeValidation = validateError['postal_code'];
      countryCodeValidation = validateError['country_code'];
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future createCustomerValidationReset({
    bool notify = false,
  }) async {
    emailValidation = '';
    firstNameValidation = '';
    lastNameValidation = '';
    companyNameValidation = '';
    baseValidation = '';
    addressLine1Validation = '';
    addressLine2Validation = '';
    cityValidation = '';
    postCodeValidation = '';
    countryCodeValidation = '';
    if (notify) {
      notifyListeners();
    }
  }
}
