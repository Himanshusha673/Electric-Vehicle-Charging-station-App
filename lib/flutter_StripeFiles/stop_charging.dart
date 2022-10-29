// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:http/http.dart';
// import 'package:stripe_payment/stripe_payment.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../../app_models/chargeBox_details_model.dart' as cdm;
// import '../../app_models/charging_scheduled_details_model.dart' as cschdm;
// import '../../app_models/charging_started_details_model.dart' as cstadm;
// import '../../app_models/direct_debit_details_model.dart' as dddm;
// import '../../app_services/app_api_collection.dart';
// import '../../app_utils/app_functions.dart';
// import '../../app_utils/connect/connect_goCardLess_payment_gateway.dart';
// import '../../app_utils/connect/connect_stripe_payment_gateway.dart';
// import '../../app_utils/connect/hive/connect_hive.dart';
// import '../../app_utils/widgets/widgets.dart';
// import '../main_screen.dart';

// class StopChargingScreen extends StatefulWidget {
//   final cstadm.ChargingStartedDetailsModel? chargingStartedDetails;
//   final cschdm.ChargingScheduledDetailsModel? chargingScheduledDetails;
//   final GlobalKey<ScaffoldState>? mainScaffoldKey;
//   const StopChargingScreen({
//     Key? key,
//     this.chargingStartedDetails,
//     this.chargingScheduledDetails,
//     this.mainScaffoldKey,
//   }) : super(key: key);

//   @override
//   _StopChargingScreenState createState() => _StopChargingScreenState();
// }

// class _StopChargingScreenState extends State<StopChargingScreen> {
//   Timer? _timer;

//   final ValueNotifier<bool> _pleaseWaitNotifier = ValueNotifier<bool>(false);

//   final StreamController _streamGetGraphData = StreamController.broadcast();

//   cdm.ChargeBoxDetailsModel? _chargeBoxDetails;
//   PaymentMethodType? _paymentMethodType;
//   String? _transactionId;
//   String? _connectorId;
//   bool _isTesterEmail = false;
//   String status = 'false';

//   Future postResnew() async {
//     String url =
//         'https://api.greenpointev.com/inindia.tech/public/api/CharingStatus/${ConnectHiveSessionData.getEmail}';
//     var response = await http.post(Uri.parse(url), headers: {
//       "Content-Type": "application/json"
//     }, body: {
//       'user': ConnectHiveSessionData.getEmail,
//       'status': status,
//     });
//     print("${response.statusCode}");
//     print("${response.body}");
//   }

//   /*_getGraphData() async {
//     var res = await Connect.postCallMethod(
//       "/stopscreen",
//       body: {
//         //"connector_id": padQuotes(widget.details['connector_id']), //"2"
//         "transaction_id": padQuotes(widget.transactionId), //"1"
//       },
//     );
//     debugPrint("stopscreen response:\t$res");
//     _streamGetGraphData.sink.add(res);
//   }*/

//   void _setChargeBoxDetails() {
//     if (widget.chargingStartedDetails != null) {
//       _chargeBoxDetails = widget.chargingStartedDetails!.chargeBoxDetails;
//       _transactionId = padQuotes(widget.chargingStartedDetails!.transactionId);
//       _connectorId = padQuotes(widget.chargingStartedDetails!.connectorId);
//       debugPrint('_chargeBoxDetails');
//     } else if (widget.chargingScheduledDetails != null) {
//       _chargeBoxDetails = widget.chargingScheduledDetails!.chargeBoxDetails;
//       _transactionId =
//           padQuotes(widget.chargingScheduledDetails!.transactionId);
//       _connectorId = padQuotes(widget.chargingScheduledDetails!.connectorId);
//     }
//   }

//   void _setPaymentMethodType() {
//     if (widget.chargingStartedDetails != null) {
//       _paymentMethodType = widget.chargingStartedDetails!.paymentMethodType;
//     } else if (widget.chargingScheduledDetails != null) {
//       _paymentMethodType = widget.chargingScheduledDetails!.paymentMethodType;
//     }
//   }

//   Future _deleteChargingDetails() async {
//     if (widget.chargingStartedDetails != null) {
//       ConnectHiveSessionData.setIsChargingStarted(false);
//       await ConnectHiveSessionData.deleteChargingStartedDetails;
//     } else if (widget.chargingScheduledDetails != null) {
//       ConnectHiveSessionData.setIsChargingScheduled(false);
//       await ConnectHiveSessionData.deleteChargingScheduledDetails;
//     }
//   }

//   Future _getGraphData() async {
//     var res = await AppApiCollection.getGraphData(
//       connectorId: _connectorId,
//       transactionId: _transactionId,
//     );
//     if (_streamGetGraphData.isClosed == false) {
//       _streamGetGraphData.sink.add(res);
//     }
//   }

//   Future _stopCharging() async {
//     var res = await AppApiCollection.remoteStop(
//       chargeBoxId: _chargeBoxDetails!.chargeBoxId,
//       transactionId: _transactionId,
//     );
//     return res;
//   }

//   Future _addHistory({required String transactionId}) async {
//     var res = await AppApiCollection.addHistory(
//       email: ConnectHiveSessionData.getEmail,
//       transactionId: transactionId,
//     );
//     return res;
//   }

//   Future _getCost() async {
//     var res = await AppApiCollection.getCost(transactionId: _transactionId);
//     return res;
//   }

//   Future<dddm.DirectDebitDetailsModel?>? _getDirectDebitData() async {
//     return ConnectHiveSessionData.getDirectDebitDetails;
//   }

//   Future<Response> _createMandate({
//     required String customerBankAccountId,
//     required String creditorBankAccountId,
//   }) async {
//     String url = 'mandates';
//     var res = await ConnectGoCardLessPaymentGateway.postCallMethod(
//       url,
//       body: {
//         'mandates': {
//           'scheme': 'bacs',
//           'links': {
//             'customer_bank_account': customerBankAccountId,
//             'creditor': creditorBankAccountId
//           }
//         }
//       },
//     );
//     debugPrint('$url Response:\t$res');
//     return res;
//   }

//   Future<Response> _makeDirectDebitPayment({
//     required num cost,
//     required String mandateId,
//   }) async {
//     String _url = 'payments';
//     Map _body = {
//       'payments': {
//         'amount': '$cost',
//         'currency': 'GBP',
//         // "charge_date": convertToCompanyDateFormat(
//         //     pattern: "yyyy-MM-dd", date: DateTime.now().toString()),
//         // "reference": "WINEBOX001",
//         // "metadata": {"order_dispatch_date": "2014-05-22"},
//         'links': {
//           'mandate': padQuotes(mandateId),
//         }
//       }
//     };
//     var res = await ConnectGoCardLessPaymentGateway.postCallMethod(
//       _url,
//       body: _body,
//     );
//     debugPrint('$_url Response:\t$res');
//     return res;
//   }

//   Future<bool> _goBack() async {
//     if (_pleaseWaitNotifier.value == true) {
//       return Future.value(false);
//     } else {
//       if (!Navigator.canPop(context)) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MainScreen(),
//           ),
//         );
//       } else {
//         Navigator.pop(context);
//       }
//       return Future.value(true);
//     }
//   }

//   @override
//   void initState() {
//     debugPrintInit(widget.runtimeType);
//     super.initState();
//     _isTesterEmail = AppConstants.testersEmailLists.any((element) =>
//         element.compareTo(padQuotes(ConnectHiveSessionData.getEmail)) == 0);
//     _setChargeBoxDetails();
//     _setPaymentMethodType();
//     _getGraphData();
//     postResnew();
//     _timer = Timer.periodic(Duration(minutes: 32), (timer) {
//       _getGraphData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _goBack,
//       child: Scaffold(
//         body: AnnotatedRegion<SystemUiOverlayStyle>(
//           value: SystemUiOverlayStyle.dark.copyWith(
//             statusBarColor: Colors.transparent,
//             statusBarIconBrightness: Brightness.dark,
//           ),
//           child: SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildAppBar,
//                 Expanded(
//                   child: RefreshIndicator(
//                     color: Theme.of(context).primaryColor,
//                     onRefresh: () async => Future.wait([
//                       _getGraphData(),
//                     ]),
//                     child: ListView(
//                       shrinkWrap: true,
//                       controller: ScrollController(),
//                       physics: AlwaysScrollableScrollPhysics(),
//                       padding: EdgeInsets.symmetric(vertical: 20.0),
//                       children: [
//                         if (_isTesterEmail == true)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 10.0),
//                             child: Center(
//                               child: Text(
//                                 'Transaction Id:\t' + padQuotes(_transactionId),
//                                 style: Theme.of(context).textTheme.headline1,
//                               ),
//                             ),
//                           ),

//                         /// Session Cost
//                         _buildCostCard,

//                         /// Session Energy
//                         _buildEnergyCard,

//                         /// Charging Speed
//                         _buildSpeedCard,
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height / 4.4),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               ValueListenableBuilder(
//                                 valueListenable: _pleaseWaitNotifier,
//                                 builder: (context, notifierValue, _) {
//                                   if (notifierValue == true) {
//                                     return _buildPleaseWaitButton;
//                                   }
//                                   return _buildStopChargingButton;
//                                 },
//                               ),
//                               Container(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 10.0),
//                                 child: Center(
//                                   child: Text(
//                                     '*Please note this may take some time to load',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle1!
//                                         .copyWith(
//                                           color: Theme.of(context).errorColor,
//                                         ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget get _buildAppBar => BuildAppBar(
//         leadingCallback: _goBack,
//         title: padQuotes(_chargeBoxDetails?.connectorDescription),
//       );

//   Widget get _buildStopChargingButton => InkWell(
//         onTap: () async {
//           switch (_paymentMethodType) {

//             /// Token ID
//             case PaymentMethodType.tokenId:
//               _goBack();
//               await _stopCharging().then((val) async {
//                 Map? res = val;
//                 if (res != null) {
//                   switch (padQuotes(res['Status'])) {

//                     /// Rejected
//                     case 'Rejected':
//                       status = 'true';
//                       showAppSnackBar(
//                         context: context,
//                         title: 'Stop Charging',
//                         response: {
//                           'errorMsg': res['Status'],
//                         },
//                       );
//                       _addHistory(transactionId: padQuotes(_transactionId));
//                       break;

//                     /// Accepted
//                     case 'Accepted':
//                       status = 'false';
//                       _addHistory(transactionId: padQuotes(_transactionId));
//                       await _deleteChargingDetails();
//                       break;
//                     default:
//                       status = 'true';
//                       showAppSnackBar(
//                         context: context,
//                         title: 'Stop Charging',
//                         response: {
//                           'warningMsg':
//                               'something went wrong, please try after some time',
//                         },
//                       );
//                       break;
//                   }
//                 }
//               });
//               break;

//             /// Card Payment
//             case PaymentMethodType.card_payment:
//               _pleaseWaitNotifier.value = true;
//               try {
//                 await _stopCharging().then((val) async {
//                   Map? res = val;
//                   if (res != null) {
//                     switch (padQuotes(res['Status'])) {

//                       /// Rejected
//                       case 'Rejected':
//                         status = 'true';
//                         _pleaseWaitNotifier.value = false;
//                         showAppSnackBar(
//                           context: context,
//                           title: 'Stop Charging',
//                           response: {
//                             'errorMsg': res['Status'],
//                           },
//                         );
//                         _addHistory(transactionId: padQuotes(_transactionId));
//                         break;

//                       /// Accepted
//                       case 'Accepted':
//                         status = 'false';
//                         _addHistory(transactionId: padQuotes(_transactionId));

//                         CreditCard? creditCard =
//                             ConnectHiveSessionData.getCardDetails;
//                         var costResponse = await _getCost();
//                         num cost = int.parse(costResponse['cost'].toString());
//                         StripeTransactionResponse transactionResponse =
//                             await ConnectStripePaymentGateway
//                                 .payViaExistingCard(
//                           amount: '$cost',
//                           currency: 'GBP',
//                           card: creditCard,
//                         );
//                         debugPrint(
//                             'transactionResponse:\t${transactionResponse.message}');

//                         await _deleteChargingDetails();

//                         _pleaseWaitNotifier.value = false;
//                         _goBack();
//                         break;
//                       default:
//                         status = 'true';
//                         showAppSnackBar(
//                           context: context,
//                           title: 'Stop Charging',
//                           response: {
//                             'warningMsg':
//                                 'something went wrong, please try after some time',
//                           },
//                         );
//                         break;
//                     }
//                   } else if (res == null) {
//                     status = 'true';
//                     _pleaseWaitNotifier.value = false;
//                     showAppSnackBar(
//                       context: context,
//                       response: {
//                         'warningMsg':
//                             'Something went wrong, please try after some time',
//                       },
//                     );
//                   }
//                 });
//               } catch (e) {
//                 status = 'true';
//                 _pleaseWaitNotifier.value = false;
//                 showAppSnackBar(
//                   context: context,
//                   response: {
//                     'warningMsg':
//                         'Something went wrong, please try after some time',
//                   },
//                 );
//               }
//               break;

//             /// Credit Card
//             case PaymentMethodType.credit_card:
//               break;

//             default:
//               break;
//           }
//         },
//         borderRadius: BorderRadius.circular(30.0),
//         child: Container(
//           margin: EdgeInsets.all(2.0),
//           padding: EdgeInsets.symmetric(vertical: 10.0),
//           decoration: BoxDecoration(
//             color: Color(0xff519657),
//             borderRadius: BorderRadius.circular(30.0),
//             boxShadow: const [
//               BoxShadow(
//                 color: Color(0x4d6924c6),
//                 offset: Offset(16.911571502685547, -2.0710700949361227e-15),
//                 blurRadius: 33.823143005371094,
//               ),
//             ],
//           ),
//           width: double.infinity,
//           child: Text(
//             'Stop Charging',
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.headline1!.copyWith(
//                   color: Colors.white,
//                 ),
//           ),
//         ),
//       );

//   Widget get _buildPleaseWaitButton => InkWell(
//         onTap: () {},
//         borderRadius: BorderRadius.circular(30.0),
//         child: Container(
//           margin: EdgeInsets.all(2.0),
//           padding: EdgeInsets.symmetric(vertical: 10.0),
//           decoration: BoxDecoration(
//             color: Color(0xff519657),
//             borderRadius: BorderRadius.circular(30.0),
//             boxShadow: const [
//               BoxShadow(
//                 color: Color(0x4d6924c6),
//                 offset: Offset(16.911571502685547, -2.0710700949361227e-15),
//                 blurRadius: 33.823143005371094,
//               ),
//             ],
//           ),
//           width: double.infinity,
//           child: Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Please Wait',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headline1!.copyWith(
//                         color: Colors.white,
//                       ),
//                 ),
//                 SizedBox(width: 20.sp),
//                 SizedBox(
//                   width: 14.sp,
//                   height: 14.sp,
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation(
//                       Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );

//   Widget _buildCard({
//     required String title,
//     required String imagePath,
//     required Widget? valueWidget,
//   }) =>
//       Card(
//         elevation: 0.0,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             /*Align(
//                 alignment: Alignment.center,
//                 child: Container(
//                   // width: 50,
//                   height: 50,
//                   child: SvgPicture.asset(
//                     padQuotes(imagePath),
//                   ),
//                 ),
//               ),*/
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       padQuotes(title),
//                       textAlign: TextAlign.start,
//                       style: Theme.of(context).textTheme.headline1,
//                     ),
//                   ),
//                   Flexible(
//                     flex: 1,
//                     child: Container(
//                       alignment: Alignment.center,
//                       width: 35.sp,
//                       height: 35.sp,
//                       child: SvgPicture.asset(
//                         padQuotes(imagePath),
//                         color: Color(0xff7F7F7F),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 3,
//                     child: valueWidget != null
//                         ? Container(
//                             alignment: Alignment.centerRight,
//                             child: valueWidget,
//                           )
//                         : Container(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget get _buildCostCard => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0),
//         child: _buildCard(
//           title: 'Session Cost',
//           imagePath: 'assets/svg/three-stacks-of-coins.svg',
//           valueWidget: StreamBuilder(
//             stream: _streamGetGraphData.stream,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 Map<String, dynamic>? data =
//                     snapshot.data as Map<String, dynamic>?;
//                 Map<String, dynamic>? details = data!['details'];
//                 return Text(
//                   '\u{00A3}' +
//                       ((double.tryParse("${details!['cost']}") != null)
//                           ? padQuotes(
//                               roundDouble(double.tryParse("${details['cost']}"))
//                                   .toStringAsFixed(2))
//                           : '- -'),
//                   textAlign: TextAlign.end,
//                   style: Theme.of(context).textTheme.headline1,
//                 );
//               } else {
//                 return CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation(
//                     Theme.of(context).primaryColor,
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       );

//   Widget get _buildEnergyCard => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0),
//         child: _buildCard(
//           title: 'Session Energy',
//           imagePath: 'assets/svg/Battery.svg',
//           valueWidget: StreamBuilder(
//             stream: _streamGetGraphData.stream,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 Map<String, dynamic>? data =
//                     snapshot.data as Map<String, dynamic>?;
//                 Map<String, dynamic>? details = data!['details'];
//                 return Text(
//                   ((double.tryParse("${details!['kWh']}") != null)
//                           ? padQuotes(
//                               roundDouble(double.tryParse("${details['kWh']}"))
//                                   .toStringAsFixed(2))
//                           : '- -') +
//                       'kWh',
//                   textAlign: TextAlign.end,
//                   style: Theme.of(context).textTheme.headline1,
//                 );
//               } else {
//                 return CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation(
//                     Theme.of(context).primaryColor,
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       );

//   Widget get _buildSpeedCard => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0),
//         child: _buildCard(
//           title: 'Charging Speed',
//           imagePath: 'assets/svg/speed.svg',
//           valueWidget: StreamBuilder(
//             stream: _streamGetGraphData.stream,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 Map<String, dynamic>? data =
//                     snapshot.data as Map<String, dynamic>?;
//                 Map<String, dynamic>? details = data!['details'];
//                 return Text(
//                   ((double.tryParse("${details!['charging_speed']}") != null)
//                           ? padQuotes(roundDouble(double.tryParse(
//                                   "${details['charging_speed']}"))
//                               .toStringAsFixed(2))
//                           : '- -') +
//                       'kW',
//                   textAlign: TextAlign.end,
//                   style: Theme.of(context).textTheme.headline1,
//                 );
//               } else {
//                 return CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation(
//                     Theme.of(context).primaryColor,
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       );

//   @override
//   void dispose() {
//     debugPrintDispose(widget.runtimeType);
//     _pleaseWaitNotifier.dispose();
//     _streamGetGraphData.close();
//     _timer?.cancel();
//     super.dispose();
//   }
// }
