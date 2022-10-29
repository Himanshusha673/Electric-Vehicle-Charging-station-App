// // ignore_for_file: constant_identifier_names

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:stripe_payment/stripe_payment.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';

// import '../app_functions.dart';

// class StripeTransactionResponse {
//   String? message;
//   bool? success;
//   String? id;

//   StripeTransactionResponse({
//     this.message,
//     this.success,
//     this.id,
//   });
// }

// class ConnectStripePaymentGateway {
//   /// BASE URLS
//   static const String _base_url_test = 'https://api.stripe.com/v1/';
//   static const String _base_url_live = 'https://api.stripe.com/v1/';

//   /// Publishable key
//   static const String _publishable_key_test =
//       'pk_test_YsmwEHsYk0mEtTwCPkvR24Ec00LKdccQNT';
//   static const String _publishable_key_live =
//       'pk_live_OqTf4WadzdlNxKJH2bNdUQfV001NyxwZIt';

//   /// Secret key
//   static const String _secret_key_test =
//       'sk_test_ipvpw71g381mamzliYP7pmO100sLGMRHOB';
//   static const String _secret_key_live =
//       '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';

//   static String get _getBaseUrl {
//     switch (AppConstants.stripeAccountType) {
//       case StripeAccountType.test:
//         return _base_url_test;
//       case StripeAccountType.live:
//         return _base_url_live;
//       default:
//         return '';
//     }
//   }

//   static String get _getPublishableKey {
//     switch (AppConstants.stripeAccountType) {
//       case StripeAccountType.test:
//         return _publishable_key_test;
//       case StripeAccountType.live:
//         return _publishable_key_live;
//       default:
//         return '';
//     }
//   }

//   static String get _getSecretKey {
//     switch (AppConstants.stripeAccountType) {
//       case StripeAccountType.test:
//         return _secret_key_test;
//       case StripeAccountType.live:
//         return _secret_key_live;
//       default:
//         return '';
//     }
//   }

//   static Map<String, String> get _getHeaders => <String, String>{
//         'Authorization': 'Bearer $_getSecretKey',
//         'Content-Type': 'application/x-www-form-urlencoded',
//       };

//   static init() {
//     StripePayment.setOptions(
//       StripeOptions(
//         publishableKey: _getPublishableKey,
//       ),
//     );
//   }

//   static Future<StripeTransactionResponse> payViaExistingCard({
//     required String amount,
//     required String currency,
//     required CreditCard? card,
//   }) async {
//     debugPrint('payViaExistingCard');
//     PaymentIntentResult paymentIntentResult;
//     PaymentMethod? paymentMethod;
//     try {
//       if (card != null) {
//         paymentMethod = await StripePayment.createPaymentMethod(
//             PaymentMethodRequest(card: card));
//       }
//       debugPrint('paymentMethod:\t${paymentMethod?.toJson()}');
//       var paymentIntent = await createPaymentIntent(amount, currency);
//       if (paymentIntent != null) {
//         debugPrint('paymentIntent:\t$paymentIntent');
//         paymentIntentResult = await StripePayment.confirmPaymentIntent(
//           PaymentIntent(
//             clientSecret: paymentIntent['client_secret'],
//             paymentMethodId: paymentMethod?.id,
//           ),
//         );
//       } else {
//         return StripeTransactionResponse(
//           success: false,
//           message: 'Transaction failed',
//         );
//       }

//       if (paymentIntentResult.status == 'succeeded') {
//         debugPrint('paymentIntentId:\t${paymentIntentResult.paymentIntentId}');
//         debugPrint('paymentMethodId:\t${paymentIntentResult.paymentMethodId}');
//         return StripeTransactionResponse(
//           success: true,
//           message: 'Transaction successful',
//           id: paymentIntentResult.paymentIntentId,
//         );
//       } else {
//         return StripeTransactionResponse(
//           success: false,
//           message: 'Transaction failed',
//         );
//       }
//     } on PlatformException catch (e) {
//       debugPrint('PlatformException:\t${e.toString()}');
//       String message = 'Something went wrong';
//       if (e.code == 'cancelled') {
//         message = 'Transaction cancelled';
//       }

//       return StripeTransactionResponse(
//         success: false,
//         message: message,
//       );
//     } catch (err) {
//       debugPrint('Exception:\t${err.toString()}');
//       return StripeTransactionResponse(
//         success: false,
//         message: 'Transaction failed: ${err.toString()}',
//       );
//     }
//   }

//   static Future<StripeTransactionResponse> payWithNewCard({
//     required String amount,
//     required String currency,
//   }) async {
//     debugPrint('payWithNewCard');
//     PaymentIntentResult response;
//     try {
//       var paymentMethod = await StripePayment.paymentRequestWithCardForm(
//           CardFormPaymentRequest());
//       debugPrint('paymentMethod:\t${paymentMethod.card!.toJson()}');
//       var paymentIntent = await createPaymentIntent(amount, currency);
//       if (paymentIntent != null) {
//         response = await StripePayment.confirmPaymentIntent(PaymentIntent(
//             clientSecret: paymentIntent['client_secret'],
//             paymentMethodId: paymentMethod.id));
//       } else {
//         return StripeTransactionResponse(
//           success: false,
//           message: 'Transaction failed',
//         );
//       }

//       if (response.status == 'succeeded') {
//         return StripeTransactionResponse(
//           success: true,
//           message: 'Transaction successful',
//         );
//       } else {
//         return StripeTransactionResponse(
//           success: false,
//           message: 'Transaction failed',
//         );
//       }
//     } on PlatformException catch (e) {
//       debugPrint('PlatformException:\t${e.toString()}');
//       String message = 'Something went wrong';
//       if (e.code == 'cancelled') {
//         message = 'Transaction cancelled';
//       }

//       return StripeTransactionResponse(
//         success: false,
//         message: message,
//       );
//     } catch (err) {
//       debugPrint('Exception:\t${err.toString()}');
//       return StripeTransactionResponse(
//         success: false,
//         message: 'Transaction failed: ${err.toString()}',
//       );
//     }
//   }

//   static Future<Map<String, dynamic>?> createPaymentIntent(
//     String amount,
//     String currency,
//   ) async {
//     debugPrint('createPaymentIntent');
//     try {
//       Uri uri = Uri.parse(_getBaseUrl + 'payment_intents');
//       Map<String, dynamic> body = {
//         'amount': amount,
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };
//       debugPrint('url:\t$uri');
//       debugPrint('body:\t$body');
//       var response = await http.post(
//         uri,
//         headers: _getHeaders,
//         body: body,
//       );
//       return jsonDecode(response.body);
//     } catch (e) {
//       debugPrint('Exception:\t${e.toString()}');
//     }
//     return Future.value(null);
//   }
// }
