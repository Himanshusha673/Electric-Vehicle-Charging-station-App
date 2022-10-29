import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as fs;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../app_models/chargeBox_details_model.dart' as cdm;
import '../../app_models/charging_scheduled_details_model.dart' as cschdm;
import '../../app_models/charging_started_details_model.dart' as cstadm;
import '../../app_providers/settings_provider.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';
import '../../flutter_StripeFiles/connect_strip_payment1.dart';
import '../settings/add_charge_card_screen.dart';
import '../settings/settings_screen.dart';
import 'stop_charging_screen.dart';

enum _Button {
  // ignore: constant_identifier_names
  start_charging,
  // ignore: constant_identifier_names
  schedule_charging,
  // ignore: constant_identifier_names
  scheduled_charging,
  // ignore: constant_identifier_names
  stop_Charging,
}

class StartChargingScreen extends StatefulWidget {
  final String? chargeBoxId;
final String chargeType;
final String tariffData;

  const StartChargingScreen({
    Key? key,
    @required this.chargeBoxId, required this.chargeType, required this.tariffData,
  }) : super(key: key);

  @override
  _StartChargingScreenState createState() => _StartChargingScreenState();
}

class _StartChargingScreenState extends State<StartChargingScreen> {
  final StreamController _streamController = StreamController();
// SetupIntent? _setupIntentResult;
  final ValueNotifier<bool> _tokenIDSwitchNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _directDebitSwitchNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> _creditCardSwitchNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> _pleaseWaitNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<_Button> _buttonNotifier =
      ValueNotifier<_Button>(_Button.start_charging);
  Map<String, dynamic>? _chargeBoxDetails;
  // var _chargeBoxDetails;
  var _chargeType=[];
  String _connectorDropdownId = '1';
  bool _isOngoingTransaction = false;
  String? _transactionId;
   List _chargeBoxList = [];
   var mapResponse={};
 List get getChargeBoxList => _chargeBoxList;
  Future postRes(String sta) async {
     var headers = {
  'Content-Type': 'application/json'
};
var request = http.Request('POST', Uri.parse('https://api.greenpointev.com/inindia.tech/public/api/CharingStatus/${ConnectHiveSessionData.getEmail}'));
request.body = json.encode({
       'user': ConnectHiveSessionData.getEmail,
      'status': sta,
});
request.headers.addAll(headers);

http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
  log("start Charging api");
  log(request.body);
  log(await response.stream.bytesToString());
  
}
else {
  print(response.reasonPhrase);
}
  }
//! Call charging status api
 Future apicall() async {
    http.Response responseL;
    //responseL=status as http.Response;
    String url ='https://api.greenpointev.com/inindia.tech/public/api/CharingStatus/${ConnectHiveSessionData.getEmail}';
    responseL = await http.get(Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    print("${responseL.statusCode}");
    print("${responseL.body}");
    
    if(responseL.statusCode == 200){
      setState(() {
        
        mapResponse = json.decode(responseL.body);
        print("data");
      });
    }
  }
  Future _loadData() async {
    await _getDirectDebitToken();
    // await _getDirectDebitData();
  //  await _getChargeBoxDetail();
    await _getChargeBoxDetails();
  }

  bool get _isPaymentMethodSelected {
    if (_tokenIDSwitchNotifier.value == false &&
        _directDebitSwitchNotifier.value == false &&
        _creditCardSwitchNotifier.value == false) {
      showAppSnackBar(
        context: context,
        title: 'Start Charging',
        response: {
          'warningMsg': 'Select Payment Method',
        },
        duration: Duration(seconds: 10),
      );
    }
    return !(_tokenIDSwitchNotifier.value == false &&
        _directDebitSwitchNotifier.value == false &&
        _creditCardSwitchNotifier.value == false);
  }

  Future<bool> checkOngoingChargeDetail() async {
    debugPrint('checkOngoingChargeDetail');
    if (ConnectHiveSessionData.getIsChargingStarted == true) {
      debugPrint(
          'getIsChargingStarted = ${ConnectHiveSessionData.getIsChargingStarted}');
      cstadm.ChargingStartedDetailsModel? _chargingStartedDetails =
          ConnectHiveSessionData.getChargingStartedDetails;
      cdm.ChargeBoxDetailsModel? _chargeBoxDetails =
          _chargingStartedDetails!.chargeBoxDetails;
      String _chargeBoxId = padQuotes(_chargeBoxDetails!.chargeBoxId);
      if (_chargeBoxId.compareTo(widget.chargeBoxId!) == 0) {
        _connectorDropdownId = padQuotes(_chargingStartedDetails.connectorId);
        switch (_chargingStartedDetails.paymentMethodType) {
          case PaymentMethodType.tokenId:
            _tokenIDSwitchNotifier.value = true;
            break;
          case PaymentMethodType.card_payment:
            _directDebitSwitchNotifier.value = true;
            break;
          case PaymentMethodType.credit_card:
            _creditCardSwitchNotifier.value = true;
            break;
          default:
            break;
        }
        _buttonNotifier.value = _Button.stop_Charging;
        return true;
      }
    } else if (ConnectHiveSessionData.getIsChargingScheduled == true) {
      debugPrint('getIsChargingScheduled = true');
      cschdm.ChargingScheduledDetailsModel? _chargingScheduledDetails =
          ConnectHiveSessionData.getChargingScheduledDetails;
      cdm.ChargeBoxDetailsModel? _chargeBoxDetails =
          _chargingScheduledDetails!.chargeBoxDetails;
      String _chargeBoxId = padQuotes(_chargeBoxDetails!.chargeBoxId);

      if (_chargeBoxId.compareTo(widget.chargeBoxId!) == 0) {
        _connectorDropdownId = padQuotes(_chargingScheduledDetails.connectorId);
        switch (_chargingScheduledDetails.paymentMethodType) {
          case PaymentMethodType.tokenId:
            _tokenIDSwitchNotifier.value = true;
            break;
          case PaymentMethodType.card_payment:
            _directDebitSwitchNotifier.value = true;
            break;
          case PaymentMethodType.credit_card:
            _creditCardSwitchNotifier.value = true;
            break;
          default:
            break;
        }
        _buttonNotifier.value = _Button.scheduled_charging;
        return true;
      }
    }
    return false;
  }

  Future _getChargeBoxDetails() async {
    var res = await AppApiCollection.getChargeBoxDetails(
        chargeBoxId: widget.chargeBoxId);
    if (_streamController.isClosed == false) {
      _streamController.sink.add(res);
    }
    return res;
  }
  //! Get ChargeType form HomeScreen API
  Future _getChargeBoxDetail() async {
    var res = await AppApiCollection.getHomeData(
       );
    if (_streamController.isClosed == false) {
      _streamController.sink.add(res);
    }
    _chargeType=res["details"];
    print(res["details"][0]["charge_type"].toString());
    return _chargeType;
  }


 



  Future _getDirectDebitToken() async {
    var res = await AppApiCollection.getDirectDebitToken(
        email: ConnectHiveSessionData.getEmail);
    if (res != null) {
      ConnectHiveSessionData.setDirectDebitToken(res['id_tag']);
      // ConnectHiveSessionData.setDirectDebitToken('DD-kboq');
    }
    return res;
  }

  Future _getDirectDebitData() async {
    var res = await AppApiCollection.getDetails(
        email: ConnectHiveSessionData.getEmail);
    if (res != null) {
      ConnectHiveSessionData.setDirectDebitDetails(res);
    }
    return res;
  }

  Future _startCharging({
    required String chargeBoxId,
    required String connectorId,
    required String? idTag,
  }) async {
    _pleaseWaitNotifier.value = true;
    var res = await AppApiCollection.remoteStart(
      chargeBoxId: chargeBoxId,
      connectorId: connectorId,
      idTag: idTag,
    );
    return res;
  }

  Future _getTimeZoneData({
    double? latitude,
    double? longitude,
  }) async {
    var res = await AppApiCollection.getTimeZoneData(
      latitude: latitude,
      longitude: longitude,
    );
    return res;
  }

  Future _scheduleCharging({
    required String chargeBoxId,
    required String connectorId,
    required String? idTag,
  }) async {
    _pleaseWaitNotifier.value = true;
    Map? _timeZoneRes = await _getTimeZoneData(
      latitude: double.tryParse(_chargeBoxDetails!['latitude']),
      longitude: double.tryParse(_chargeBoxDetails!['longitude']),
    );
    if (_timeZoneRes == null) {
      return {
        'errorMsg': 'something went wrong, Please try after some time',
      };
    }

    num _gmtOffset = num.parse("${_timeZoneRes['gmt_offset']}");

    var res = await AppApiCollection.remoteSchedule(
      chargeBoxId: chargeBoxId,
      connectorId: connectorId,
      idTag: idTag,
      gmtOffset: _gmtOffset,
      chargeStartTime: ConnectHiveSessionData.getChargeStartTime,
      chargeEndTime: ConnectHiveSessionData.getChargeEndTime,
    );
    return res;

    /*TimeOfDay _timeZoneTime =
        TimeOfDay.fromDateTime(DateTime.parse("${_timeZoneRes['datetime']}"));
    TimeOfDay _chargeStartTime =
        timeToTimeOfDay(ConnectHiveSessionData.getChargeStartTime);
    int compare =
        compareTime(startTime: _chargeStartTime, endTime: _timeZoneTime);

    if (compare > 0) {
      String _url = "RemoteStart";
      Map _body = {
        "ChargeBoxId": chargeBoxId,
        "ConnectorId": connectorId,
        "IdTag": idTag,
        "ChargingProfile": {
          "StackLevel": 0,
          "ChargingProfilePurpose": "TxProfile",
          "ChargingProfileKind": "Recurring",
          "Recurrencykind": "Daily",
          "ChargingSchedule": {
            "Duration": 86400,
            "StartSchedule": "2021-04-02T00:00:00.000Z",
            "ChargingRateUnit": "A",
            "ChargingSchedulePeriod": [
              {
                "StartPeriod": 0,
                "Limit": 0,
              },
              {
                "StartPeriod":
                    timeToSecond(ConnectHiveSessionData.getChargeStartTime) -
                        (_gmtOffset * 3600),
                "Limit": 32,
              },
              {
                "StartPeriod":
                    timeToSecond(ConnectHiveSessionData.getChargeEndTime) -
                        (_gmtOffset * 3600),
                "Limit": 0,
              },
            ]
          }
        }
      };
      var res = await ConnectRemote.postCallMethod(
        _url,
        body: _body,
      );
      debugPrint("$_url response:\t$res");
      return res;
    } else if (compare == 0 || compare < 0) {
      return {
        "chargeStartError": "Please choose the future time for Charge Start",
      };
    }*/
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _initialization();
    
  }

  void _initialization() async {
    bool ongoing = await checkOngoingChargeDetail();
    if (ongoing == false) {
      (padQuotes(ConnectHiveSessionData.getIdTag).isNotEmpty)
          ? _tokenIDSwitchNotifier.value = true
          : _tokenIDSwitchNotifier.value = false;

      /// Initializing Button
      switch (ConnectHiveSessionData.getIsSmartChargingEnabled) {
        case true:
          _buttonNotifier.value = _Button.schedule_charging;
          break;
        default:
          _buttonNotifier.value = _Button.start_charging;
          break;
      }
    }
    _isOngoingTransaction =
        (ConnectHiveSessionData.getIsChargingStarted == true ||
            ConnectHiveSessionData.getIsChargingScheduled == true);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              debugPrint(
                  'snapshot.connectionState:\t${snapshot.connectionState}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoader;
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? data =
                      snapshot.data as Map<String, dynamic>?;
                    // log("here ${data!["details"]["charge_box_id"].toString()}");
                  _chargeBoxDetails = data!['details'];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar,
                      Expanded(
                        child: RefreshIndicator(
                          color: Theme.of(context).primaryColor,
                          onRefresh: () async => Future.wait(
                            [
                              _loadData(),
                            ],
                          ),
                          child: ListView(
                            shrinkWrap: true,
                            controller: ScrollController(),
                            physics: AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            children: [
                              Divider(),
                              _buildChargerAvailability,
                              SizedBox(
                                height: 20,
                                child: Divider(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: BuildConnectorDropdown(
                                  title: 'Connector',
                                  initialValue: _connectorDropdownId,
                                  listData:
                                      _chargeBoxDetails!['connector_list'],
                                  onChange: (val) {
                                    if (_pleaseWaitNotifier.value != true) {
                                      _connectorDropdownId = val.value!;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                child: Divider(),
                              ),
                              _buildCard,
                              SizedBox(
                                height: 40,
                                child: Divider(),
                              ),
                              
                              _buildPaymentMethodCard,
                        //      //! Try CreditCard  Payment Option
                        //       TextButton(onPressed: () async{
                        //          fs.CardDetails? creditCard =
                        //     ConnectHiveSessionData.getCardDetails;
                        //         //  num cost = int.parse(costResponse['cost'].toString());
                        // StripeTransactionResponse transactionResponse =
                        //     await ConnectStripePaymentGateway
                        //         .payViaExistingCard(
                        //           transId: _transactionId??'data',
                        //   amount: '100',
                        //   currency: 'GBP',
                        //   card: creditCard,
                        // );
                        // log("Credit Card");
                        //       }, child: Text("Check Credit Card")),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _pleaseWaitNotifier,
                                  builder: (context, waitNotifier, _) {
                                    if (waitNotifier) {
                                      return _buildPleaseWaitButton;
                                    }
                                    return ValueListenableBuilder<_Button>(
                                      valueListenable: _buttonNotifier,
                                      builder: (context, buttonNotifier, _) {
                                        switch (buttonNotifier) {

                                          /// schedule Charging
                                          case _Button.schedule_charging:
                                            return _buildScheduleChargingButton;

                                          /// scheduled Charging
                                          case _Button.scheduled_charging:
                                            return _buildScheduledChargingButton;

                                          /// stop charging
                                          case _Button.stop_Charging:
                                            return _buildStopChargingButton;

                                          /// Default => start Charging
                                          default:
                                            return _buildStartChargingButton;
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BuildAppBar(
                      title: '',
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                              'something went wrong, Please try after some time'),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget get _buildLoader {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget get _buildPaymentMethodCard {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Payment Method',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20),

              /// Token ID
              _buildPaymentType(
                title: 'Token ID',
                switchNotifier: _tokenIDSwitchNotifier,
                callback: (val) {
                  if (_pleaseWaitNotifier.value != true) {
                    if (val &&
                        padQuotes(ConnectHiveSessionData.getIdTag).isEmpty) {
                      _showSnackBar(
                        title: 'Add Charge Card',
                        callback: () async {
                          await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AddChargeCardScreen(),
                            ),
                          ).then((value) {
                            Map? res = value;
                            if (res != null && res.containsKey('successMsg')) {
                              _tokenIDSwitchNotifier.value = val;
                              _directDebitSwitchNotifier.value = !val;
                              _creditCardSwitchNotifier.value = !val;
                            }
                          });
                        },
                      );
                    } else if (val) {
                      _tokenIDSwitchNotifier.value = val;
                      _directDebitSwitchNotifier.value = !val;
                      _creditCardSwitchNotifier.value = !val;
                    } else {
                      _tokenIDSwitchNotifier.value = val;
                    }
                  }
                },
              ),
              SizedBox(height: 20),

              /// Card Payment
              _buildPaymentType(
                title: 'Card Payment',
                switchNotifier: _directDebitSwitchNotifier,
                callback: (val) {
                  if (_pleaseWaitNotifier.value != true) {
                    if (val == true &&
                         ConnectHive.boxSessionData.get('cardDetails') != null) {
                      _directDebitSwitchNotifier.value = val;
                      _tokenIDSwitchNotifier.value = !val;
                      _creditCardSwitchNotifier.value = !val;
                    } else if (val == true &&
                         ConnectHive.boxSessionData.get('cardDetails') == null) {
                      _showSnackBar(
                        title: 'Card Payment',
                        callback: () async {
                          await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                  create: (context) => SettingsProvider(),
                                  builder: (context, child) => child!,
                                  child: SettingsScreen()),
                            ),
                          );
                          // await _getDirectDebitData();
                          fs.CardDetails? creditCard =
                              ConnectHiveSessionData.getCardDetails;
                          if (creditCard != null &&
                              creditCard.number!.isNotEmpty) {
                            _directDebitSwitchNotifier.value = val;
                            _tokenIDSwitchNotifier.value = !val;
                            _creditCardSwitchNotifier.value = !val;
                          }
                        },
                      );
                    } else {
                      _directDebitSwitchNotifier.value = val;
                    }
                  }
                },
              ),
              SizedBox(height: 20),

              /// Credit Card
              /*Tooltip(
                message: "credit card feature coming soon",
                child: _buildPaymentType(
                  title: "Credit Card",
                  switchNotifier: _creditCardSwitchNotifier,
                  callback: (val) {
                    */ /*if (val) {
                      _creditCardSwitchNotifier.value = val;
                      _tokenIDSwitchNotifier.value = !val;
                      _directDebitSwitchNotifier.value = !val;
                    } else {
                      _creditCardSwitchNotifier.value = val;
                    }*/ /*
                  },
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar({
    required String title,
    required VoidCallback callback,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 10),
        content: Text(
          title,
          style: Theme.of(context).textTheme.headline6!.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
        ),
        action: SnackBarAction(
          label: 'Configure',
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            callback();
          },
        ),
      ),
    );
  }

  Widget _buildPaymentType({
    required String title,
    required ValueNotifier<bool> switchNotifier,
    ValueChanged<bool>? callback,
  }) {
    return Container(
      padding: EdgeInsets.only(right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            padQuotes(title),
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          BuildSwitch(
            switchNotifier: switchNotifier,
            callback: callback,
          ),
        ],
      ),
    );
  }

  Widget get _buildAppBar => BuildAppBar(
        title: padQuotes(_chargeBoxDetails!['street']),
      );

  Widget get _buildChargerAvailability {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      width: double.infinity,
      child: Center(
        child: Text(
          toBeginningOfSentenceCase(
              padQuotes(_chargeBoxDetails!['connector_status']))!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  /// Start Charging Button
  Widget get _buildStartChargingButton {
    return InkWell(
      onTap: () async {
        if (_isOngoingTransaction == true) {
          showAppSnackBar(
            context: context,
            title: 'Start Charging',
            response: {
              'warningMsg':
                  'Please stop the ongoing transaction to Start Charging',
            },
          );
        } else {
          if (_isPaymentMethodSelected == true) {
            PaymentMethodType? paymentMethodType;
            String? idTag;
            if (_tokenIDSwitchNotifier.value == true) {
              paymentMethodType = PaymentMethodType.tokenId;
            } else if (_directDebitSwitchNotifier.value == true) {
              paymentMethodType = PaymentMethodType.card_payment;
            } else if (_creditCardSwitchNotifier.value == true) {
              paymentMethodType = PaymentMethodType.credit_card;
            }
            switch (paymentMethodType!) {
              case PaymentMethodType.tokenId:
                idTag = padQuotes(ConnectHiveSessionData.getIdTag);
                break;
              case PaymentMethodType.card_payment:
                idTag = padQuotes(ConnectHiveSessionData.getDirectDebitToken);
                break;
              case PaymentMethodType.credit_card:
                break;
            }
            try {
              await _startCharging(
                chargeBoxId: padQuotes(_chargeBoxDetails!['charge_box_id']),
                connectorId: _connectorDropdownId,
                idTag: idTag,
              ).then((val) async {
                Map<String, dynamic>? res = val;
                if (res != null) {
                  switch (padQuotes(res['Status'])) {
                    case 'Rejected':
                      // status = 'false';
                      _pleaseWaitNotifier.value = false;
                      showAppSnackBar(
                        context: context,
                        title: 'Start Charging',
                        response: {
                          'errorMsg': 'Rejected',
                        },
                      );
                      break;
                    case 'Accepted':
                      // status = 'true';
                      _transactionId = padQuotes(res['TransactionId']);
                      ConnectHiveSessionData.setIsChargingStarted(true);
                      ConnectHiveSessionData.setChargingStartedDetails(
                        chargingStartedDetails:
                            cstadm.ChargingStartedDetailsModel(
                          chargeBoxDetails: cdm.ChargeBoxDetailsModel.fromJson(
                              _chargeBoxDetails!),
                          connectorId: _connectorDropdownId,
                          transactionId: _transactionId,
                          idTag: idTag,
                          paymentMethodType: paymentMethodType,
                        ),
                      );
                      _pleaseWaitNotifier.value = false;
                      postRes('true');
                     
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StopChargingScreen(
                            chargingStartedDetails: ConnectHiveSessionData
                                .getChargingStartedDetails,
                          ),
                        ),
                      );
                      break;
                    default:
                      // status = 'false';
                      showAppSnackBar(
                        context: context,
                        title: 'Start Charging',
                        response: {
                          'warningMsg':
                              'something went wrong, please try after some time',
                        },
                      );
                      break;
                  }
                } else if (res == null) {
                  // status = 'false';
                  _pleaseWaitNotifier.value = false;
                  showAppSnackBar(
                    context: context,
                    response: {
                      'warningMsg':
                          'Something went wrong, please try after some time',
                    },
                  );
                }
              });
            } catch (e) {
              debugPrint('e:\t${e.toString()}');
              // status = 'false';
              _pleaseWaitNotifier.value = false;
              showAppSnackBar(
                context: context,
                response: {
                  'warningMsg':
                      'Something went wrong, please try after some time',
                },
              );
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xffFB8C00),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4d6924c6),
              offset: Offset(16.911571502685547, -2.0710700949361227e-15),
              blurRadius: 33.823143005371094,
            ),
          ],
        ),
        width: double.infinity,
        child: Text(
          'Start Charging',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

  /// Schedule Charging Button
  Widget get _buildScheduleChargingButton {
    return InkWell(
      onTap: () async {
        if (_isOngoingTransaction == true) {
          // status = 'false';
          showAppSnackBar(
            context: context,
            title: 'Start Charging',
            response: {
              'warningMsg':
                  'Please stop the ongoing transaction to Schedule Charging',
            },
          );
        } else {
          if (_isPaymentMethodSelected == true) {
            PaymentMethodType? paymentMethodType;
            String? idTag;
            if (_tokenIDSwitchNotifier.value == true) {
              paymentMethodType = PaymentMethodType.tokenId;
            } else if (_directDebitSwitchNotifier.value == true) {
              paymentMethodType = PaymentMethodType.card_payment;
            } else if (_creditCardSwitchNotifier.value == true) {
              paymentMethodType = PaymentMethodType.credit_card;
            }
            debugPrint('paymentMethodType:\t$paymentMethodType');
            switch (paymentMethodType) {
              case PaymentMethodType.tokenId:
                idTag = padQuotes(ConnectHiveSessionData.getIdTag);
                break;
              case PaymentMethodType.card_payment:
                idTag = padQuotes(ConnectHiveSessionData.getDirectDebitToken);
                break;
              case PaymentMethodType.credit_card:
                break;
              default:
                break;
            }
            debugPrint('idTag:\t$idTag');
            await _scheduleCharging(
              chargeBoxId: padQuotes(_chargeBoxDetails!['charge_box_id']),
              connectorId: _connectorDropdownId,
              idTag: idTag,
            ).then((val) async {
              Map? res = val;
              if (res != null) {
                if (res.containsKey('chargeStartError')) {
                  _pleaseWaitNotifier.value = false;
                  _showSnackBar(
                    title: res['chargeStartError'],
                    callback: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                              create: (context) => SettingsProvider(),
                              builder: (context, child) => child!,
                              child: SettingsScreen()),
                        ),
                      );
                    },
                  );
                } else if (res.containsKey('errorMsg')) {
                  showAppSnackBar(
                    context: context,
                    title: 'Schedule Charging',
                    response: res,
                  );
                } else if (res.containsKey('Status')) {
                  switch (padQuotes(res['Status'])) {
                    case 'Rejected':
                      _pleaseWaitNotifier.value = false;
                      showAppSnackBar(
                        context: context,
                        title: 'Schedule Charging',
                        response: {
                          'errorMsg': 'Rejected',
                        },
                      );
                      break;
                    case 'Accepted':
                      _transactionId = padQuotes(res['TransactionId']);
                      ConnectHiveSessionData.setIsSmartChargingEnabled(false);
                      ConnectHiveSessionData.setIsChargingScheduled(true);
                      ConnectHiveSessionData.setChargingScheduledDetails(
                        chargingScheduledDetails:
                            cschdm.ChargingScheduledDetailsModel(
                          chargeBoxDetails: cdm.ChargeBoxDetailsModel.fromJson(
                              _chargeBoxDetails!),
                          connectorId: _connectorDropdownId,
                          idTag: idTag,
                          paymentMethodType: paymentMethodType,
                          transactionId: _transactionId,
                          date: DateTime.now().toString().split(' ')[0],
                          startTime: ConnectHiveSessionData.getChargeStartTime,
                          endTime: ConnectHiveSessionData.getChargeEndTime,
                        ),
                      );

                      _pleaseWaitNotifier.value = false;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StopChargingScreen(
                            chargingScheduledDetails: ConnectHiveSessionData
                                .getChargingScheduledDetails,
                          ),
                        ),
                      );
                      _buttonNotifier.value = _Button.scheduled_charging;
                      break;
                  }
                }
              }
            });
            _pleaseWaitNotifier.value = false;
          }
        }
      },
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xffFB8C00),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4d6924c6),
              offset: Offset(16.911571502685547, -2.0710700949361227e-15),
              blurRadius: 33.823143005371094,
            ),
          ],
        ),
        width: double.infinity,
        child: Text(
          'Schedule Charging',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

  Widget get _buildScheduledChargingButton {
    return InkWell(
      onTap: () async {
        if (ConnectHiveSessionData.getIsChargingScheduled == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StopChargingScreen(
                chargingScheduledDetails:
                    ConnectHiveSessionData.getChargingScheduledDetails,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xffFB8C00),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4d6924c6),
              offset: Offset(16.911571502685547, -2.0710700949361227e-15),
              blurRadius: 33.823143005371094,
            ),
          ],
        ),
        width: double.infinity,
        child: Text(
          'Charging Scheduled',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

  Widget get _buildStopChargingButton {
    return InkWell(
      onTap: () async {
        if (ConnectHiveSessionData.getIsChargingStarted == true) {
          // postRes('false');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StopChargingScreen(
                chargingStartedDetails:
                    ConnectHiveSessionData.getChargingStartedDetails,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xffFB8C00),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4d6924c6),
              offset: Offset(16.911571502685547, -2.0710700949361227e-15),
              blurRadius: 33.823143005371094,
            ),
          ],
        ),
        width: double.infinity,
        child: Text(
          'Stop Charging',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

  Widget get _buildPleaseWaitButton {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () async {},
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            margin: EdgeInsets.all(2.0),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: Color(0xffFB8C00),
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4d6924c6),
                  offset: Offset(16.911571502685547, -2.0710700949361227e-15),
                  blurRadius: 33.823143005371094,
                ),
              ],
            ),
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please Wait',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  SizedBox(width: 20.sp),
                  SizedBox(
                    height: 14.sp,
                    width: 14.sp,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get _buildCard {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 23.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color:Theme.of(context).primaryColor,)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Charger",
                      // _chargeBoxDetails!["charge_box_id"],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(height: 3,),
                    Text(
                      // '7KW',
                      widget.chargeType,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 23.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border:Border.all(color: Colors.green)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tariff',
                      // _chargeBoxDetails!["charge_box_id"],
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    // Container(
                    //   padding: EdgeInsets.only(right: 10.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       // Text(
                    //       //   'Peak',
                    //       //   textAlign: TextAlign.start,
                    //       //   style: Theme.of(context).textTheme.bodyText1,
                    //       // ),
                    //       Text(
                    //         (_chargeBoxDetails!['tariff'][0] != null)
                    //             ? '\u{00A3}'
                    //                 "${roundDouble(double.parse("${_chargeBoxDetails!['tariff'][0]['max']}"), 2)}"
                    //                 'p'
                    //             : 'NA',
                    //         textAlign: TextAlign.end,
                    //         style: Theme.of(context).textTheme.bodyText1,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 3,),
                    Container(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Text(
                        // (_chargeBoxDetails!['tariff'][1] != null)
                        //     ? '\u{00A3}'
                        //         "${roundDouble(double.parse("${_chargeBoxDetails!['tariff'][1]['min']}"), 2)}"
                        //         '/ kWh'
                        //     : 'NA',
                        '£'+widget.tariffData+'/ kWh',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    _streamController.close();
    _tokenIDSwitchNotifier.dispose();
    _directDebitSwitchNotifier.dispose();
    _creditCardSwitchNotifier.dispose();
    _pleaseWaitNotifier.dispose();
    super.dispose();
  }
}