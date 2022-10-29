// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as fs;
import '../../app_models/charging_started_details_model.dart' as cstadm;
import '../app_models/direct_debit_details_model.dart';
import '../app_utils/app_constants.dart';
import '../app_utils/app_enums.dart';
import '../app_utils/app_functions.dart';
import '../app_utils/connect/connect_api.dart';
import '../app_utils/connect/hive/connect_hive.dart';



class StripeTransactionResponse {
  String? message;
  bool? success;
  String? id;

  StripeTransactionResponse({
    this.message,
    this.success,
    this.id,
  });
}

class ConnectStripePaymentGateway {
  /// BASE URLS
  static const String _base_url_test = 'https://api.stripe.com/v1/';
  static const String _base_url_live = 'https://api.stripe.com/v1/';


  /// Publishable key
  static const String _publishable_key_test =
      'pk_test_YsmwEHsYk0mEtTwCPkvR24Ec00LKdccQNT';
  static const String _publishable_key_live =
      'pk_live_OqTf4WadzdlNxKJH2bNdUQfV001NyxwZIt';

  /// Secret key
  static const String _secret_key_test =
      'sk_test_ipvpw71g381mamzliYP7pmO100sLGMRHOB';
  static const String _secret_key_live =
      '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';
  late final cstadm.ChargingStartedDetailsModel? chargingStartedDetails;
//! For Testing
String? transI;
  // static String get _getBaseUrl {
  //   return _base_url_test;
  // }
  static String get _getBaseUrl {
    switch (AppConstants.stripeAccountType) {
      case StripeAccountType.test:
        return _base_url_test;
      case StripeAccountType.live:
        return _base_url_live;
      default:
        return '';
    }
  }

 
 
  static String get _getPublishableKey {
    switch (AppConstants.stripeAccountType) {
      case StripeAccountType.test:
        return _publishable_key_test;
      case StripeAccountType.live:
        return _publishable_key_live;
      default:
        return '';
    }
  }
  // static String get _getPublishableKey {
    
  //       return _publishable_key_test;
  //   }
  

 
  // static String get _getSecretKey {
   
  //       return _secret_key_test;
  //   }
  
  static String get _getSecretKey {
    switch (AppConstants.stripeAccountType) {
      case StripeAccountType.test:
        return _secret_key_test;
      case StripeAccountType.live:
        return _secret_key_live;
      default:
        return '';
    }
  }

  static Map<String, String> get _getHeaders => <String, String>{
        'Authorization': 'Bearer $_getSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      };
  static Map<String, String> get checkPaymentHeader => <String, String>{
        'Accept':'application/json',
        // 'Content-Type': 'application/json',
      };

  static init() {
    fs.Stripe.publishableKey=
      
         _getPublishableKey
     ;
  }

  static Future<StripeTransactionResponse> payViaExistingCard({
     fs.PaymentMethodData? paymentMethodData,
    required String amount,
    required String currency,
    required String transId,
    required fs.CardDetails? card,
  }) async {
    debugPrint('payViaExistingCard');
    fs.PaymentIntent paymentIntentResult;
    fs.PaymentMethod? paymentMethod;
    try {
      log("$paymentMethod");
      if ( card != null) {
        paymentMethod = await fs.Stripe.instance.createPaymentMethod(
          
            fs.PaymentMethodParams.card(paymentMethodData: fs.PaymentMethodData(billingDetails: fs.BillingDetails(name: ''))));
      }
    
      debugPrint('paymentMethod:\t${paymentMethod?.toJson()}');
      var paymentIntent = await createPaymentIntent(amount, currency);
      if (paymentIntent != null) {
        debugPrint('paymentIntent:\t$paymentIntent');
        paymentIntentResult = await fs.Stripe.instance.confirmPayment(
           paymentIntent['client_secret'],
           
             fs.PaymentMethodParams.card(paymentMethodData: fs.PaymentMethodData(billingDetails: fs.BillingDetails())),
             
        
          
        );
        log("Update Payment status in api");
   checkPaymentStatus(transId,amount, currency, paymentIntentResult.status.toString(),);
        log('Payment Intent result : ${paymentIntentResult.status}');
      } else {
        return StripeTransactionResponse(
          success: false,
          message: 'Transaction failed',
        );
        
      }

      // ignore: unrelated_type_equality_checks
      if (paymentIntentResult.status == PaymentIntentsStatus.Succeeded) {
        log('Success');
        // checkPaymentStatus(transId,amount, currency, paymentIntentResult.status.toString(),);
        debugPrint('paymentIntentId:\t${paymentIntentResult.id}');
        debugPrint('paymentMethodId:\t${paymentIntentResult.paymentMethodId}');
        return StripeTransactionResponse(
          success: true,
          message: 'Transaction successful',
          id: paymentIntentResult.id,
        );
      } else {
         checkPaymentStatus(transId,amount, currency, paymentIntentResult.status.toString());
         log(paymentIntentResult.status.toString());
        return StripeTransactionResponse(
          success: false,
          message: 'Transaction failed',
        );
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException:\t${e.toString()}');
      log("2"+e.toString());
      String message = 'Something went wrong';
      if (e.code == 'cancelled') {
        message = 'Transaction cancelled';
      }

      return StripeTransactionResponse(
        success: false,
        message: message,
      );
    } catch (err) {
      debugPrint('Exception:\t${err.toString()}');
      log("3"+err.toString());
      return StripeTransactionResponse(
        success: false,
        message: 'Transaction failed: ${err.toString()}',
      );
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard({
    fs.PaymentMethodData? paymentMethodData,
    required String amount,
    required String currency,
  }) async {
    debugPrint('payWithNewCard');
    fs.PaymentIntent response;
    try {
      var paymentMethod = await fs.CardDetails(
          );
      debugPrint('paymentMethod:\t${paymentMethod.toJson()}');
      
      var paymentIntent = await createPaymentIntent(amount, currency);
      if (paymentIntent != null) {
        response = await fs.Stripe.instance.confirmPayment(
         paymentIntent['client_secret'],
            fs.PaymentMethodParams.card(paymentMethodData: paymentMethodData!)
            );
      } else {
        return StripeTransactionResponse(
          success: false,
          message: 'Transaction failed',
        );
      }

      // ignore: unrelated_type_equality_checks
      if (response.status == PaymentIntentsStatus.Succeeded) {
        
        return StripeTransactionResponse(
          success: true,
          message: 'Transaction successful',
        );
      } else {
        return StripeTransactionResponse(
          success: false,
          message: 'Transaction failed',
        );
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException:\t${e.toString()}');
      String message = 'Something went wrong';
      if (e.code == 'cancelled') {
        message = 'Transaction cancelled';
      }

      return StripeTransactionResponse(
        success: false,
        message: message,
      );
    } catch (err) {
      debugPrint('Exception:\t${err.toString()}');
      return StripeTransactionResponse(
        success: false,
        message: 'Transaction failed: ${err.toString()}',
      );
    }
  }


static Future checkPaymentStatus(String transID,
    String amount,
    String currency,
    String status,) async {
     var headers = {
  'Content-Type': 'application/json'
};
var request = http.Request('POST', Uri.parse('https://api.greenpointev.com/inindia.tech/public/api/CardTransaction'));
request.body = json.encode({
       'transaction_id':transID,
        'ref_user': ConnectHiveSessionData.getEmail,
        'status':status,
        'amount': amount,
        'currency': currency,
        'payment_method_types': 'card',
});
request.headers.addAll(headers);

http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
  log("check Payment Status");
  log(request.body);
  log(await response.stream.bytesToString());
  
}
else {
  print(response.reasonPhrase);
}
  }

  // static Future<Map<String, dynamic>?> checkPaymentStatus(
  //   String? transID,
  //   String amount,
  //   String currency,
  //   String status,
  // ) async {
  //   debugPrint('checkPaymentStatus');
  //   try {
  //     Uri uri = Uri.parse('https://api.greenpointev.com/inindia.tech/public/api/CardTransaction');
  //     Map<String, dynamic> body = {
  //       'transaction_id':transID,
  //       'ref_user': ConnectHiveSessionData.getEmail,
  //       'status':status,
  //       'amount': amount,
  //       'currency': currency,
  //       'payment_method_types[]': 'card',
  //     };
  //     debugPrint('url:\t$uri'); 
  //     debugPrint('body:\t$body');
  //     debugPrint('body:\t${body["amount"]}');
  //     var response = await http.post(
  //       uri,
  //       headers: checkPaymentHeader,
  //       body: body,
  //     );
  //     return jsonDecode(response.body);
  //   } catch (e) {
  //     debugPrint('Exception:\t${e.toString()}');
  //   }
  //   return Future.value(null);
  // }

  //Create Payment
  static Future<Map<String, dynamic>?> createPaymentIntent(
    String amount,
    String currency,
    
  ) async {
    debugPrint('createPaymentIntent');
    try {
      Uri uri = Uri.parse(_getBaseUrl + 'payment_intents');
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      debugPrint('url:\t$uri'); 
      debugPrint('body:\t$body');
      debugPrint('body:\t${body["amount"]}');
      var response = await http.post(
        uri,
        headers: _getHeaders,
        body: body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception:\t${e.toString()}');
    }
    return Future.value(null);
  }
}
