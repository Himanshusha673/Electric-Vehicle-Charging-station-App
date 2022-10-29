import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../app_providers/on_boarding_provider.dart';
import '../../app_providers/settings_provider.dart';
import '../onBoarding/sign_in_screen.dart';
import '../pdf_view_screen.dart';
import 'add_charge_card_screen.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';
import '../stripe/stripe_card_list_screen.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? mainScaffoldKey;

  const SettingsScreen({
    Key? key,
    this.mainScaffoldKey,
  }) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay? _chargeStart;
  TimeOfDay? _chargeEnd;
  String respon='';
  final ValueNotifier<bool> _switchNotifier = ValueNotifier<bool>(false);

  _getDirectDebitDetails() async {
    var res = await AppApiCollection.getDetails(
        email: ConnectHiveSessionData.getEmail);
    if (res != null) {
      ConnectHiveSessionData.setDirectDebitDetails(res);
    }
    return res;
  }

Future deleteAccountApiCall() async {
     var headers = {
  'Content-Type': 'application/json'
};
var request = http.Request('POST', Uri.parse('https://api.greenpointev.com/inindia.tech/public/api/app/request/optout/${ConnectHiveSessionData.getEmail}'));
request.body = json.encode({
       'user': ConnectHiveSessionData.getEmail,
      'deleteMe': 'true',
});
request.headers.addAll(headers);

http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
  respon = 'Account deletion requested successfully. It will take up-to 24 hour to proceed your request, You can still login to your account in this deletion period. To cancel the request please mail us at support@greenpointev.com';
  log('Delete Account');
  log(request.body);
  log(await response.stream.bytesToString());
  
}
else {
  respon = response.stream.bytesToString().toString();
  print(response.reasonPhrase);
}
  }
  void _initialize() {
    // _getDirectDebitDetails();
    if (ConnectHiveSessionData.getIsSmartChargingEnabled == true) {
      debugPrint(
          'ConnectHiveSessionData.getIsSmartChargingEnabled:\t${ConnectHiveSessionData.getIsSmartChargingEnabled}');
      _switchNotifier.value = true;
      _chargeStart =
          timeToTimeOfDay(padQuotes(ConnectHiveSessionData.getChargeStartTime));
      _chargeEnd =
          timeToTimeOfDay(padQuotes(ConnectHiveSessionData.getChargeEndTime));
    } else {
      debugPrint(
          'ConnectHiveSessionData.getIsSmartChargingEnabled:\t${ConnectHiveSessionData.getIsSmartChargingEnabled}');
      _switchNotifier.value = false;
      _chargeStart =
          (padQuotes(ConnectHiveSessionData.getChargeStartTime).isNotEmpty)
              ? timeToTimeOfDay(
                  padQuotes(ConnectHiveSessionData.getChargeStartTime))
              : TimeOfDay.now();
      _chargeEnd = (padQuotes(ConnectHiveSessionData.getChargeEndTime)
              .isNotEmpty)
          ? timeToTimeOfDay(padQuotes(ConnectHiveSessionData.getChargeEndTime))
          : TimeOfDay.now();
      debugPrint('_chargeStart:\t$_chargeStart');
      debugPrint('_chargeEnd:\t$_chargeEnd');
    }
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        /*floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            StripeTransactionResponse stripeTransactionResponse =
                await ConnectStripePaymentGateway.payViaExistingCard(
              amount: "200",
              currency: "GBP",
              card: ConnectHiveSessionData.getCardDetails,
            );
            debugPrint("stripeTransactionResponse:");
            debugPrint("id:\t${stripeTransactionResponse.id}");
            debugPrint("message:\t${stripeTransactionResponse.message}");
            debugPrint("success:\t${stripeTransactionResponse.success}");
          },
        ),*/
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Consumer<SettingsProvider>(
            builder: (context, service, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar,
                  _buildBody(service),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar {
    return BuildAppBar(
      title: 'Settings',
      leading: (widget.mainScaffoldKey != null) ? Container() : null,
    );
  }

  Widget _buildBody(
    SettingsProvider service,
  ) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        controller: ScrollController(),
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        children: <Widget>[
          /// Payment Method
          _buildHeading('Payment Method'),

          /// Token ID
          _buildPaymentType(
            title: 'Token ID',
            callback: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddChargeCardScreen(),
                ),
              );
            },
          ),

          /// Card Payment
          _buildPaymentType(
            title: 'Card Payment',
            callback: () async {
              /*StripeTransactionResponse transactionResponse =
                  await ConnectStripePaymentGateway.payViaExistingCard(
                amount: "100",
                currency: "GBP",
                card: ConnectHiveSessionData.getCardDetails,
              );
              debugPrint(
                  "transactionResponse:\t${transactionResponse.message}");*/
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StripeCardListScreen(),
                ),
              );
            },
          ),

          /// Card Payment
          /*Tooltip(
            message: "Credit card feature coming soon",
            preferBelow: false,
            child: _buildPaymentType(
              title: "Card Payment",
              callback: () async {},
            ),
          ),*/

          SizedBox(
            height: 40,
            child: Divider(),
          ),

          /// My Charger
          _buildHeading('My Charger'),

          /// Smart Charging
          ListTile(
            contentPadding: EdgeInsets.only(left: 20.0),
            leading: Text(
              'Smart Charging',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: StreamBuilder<BoxEvent>(
              stream: ConnectHiveSessionData.watchIsSmartChargingEnabled,
              builder: (context, snapshot) {
                if (ConnectHiveSessionData.getIsSmartChargingEnabled == true) {
                  _switchNotifier.value = true;
                } else {
                  _switchNotifier.value = false;
                }
                return BuildSwitch(
                  switchNotifier: _switchNotifier,
                  callback: (val) async {
                    if (val) {
                      if (_chargeStart != null && _chargeEnd != null) {
                        int compareChargeStartEnd = compareTime(
                            startTime: _chargeStart!, endTime: _chargeEnd!);

                        if (compareChargeStartEnd < 0) {
                          ConnectHiveSessionData.setChargeStartTime(
                              timeOfDayToTime(_chargeStart!));
                          ConnectHiveSessionData.setChargeEndTime(
                              timeOfDayToTime(_chargeEnd!));
                          ConnectHiveSessionData.setIsSmartChargingEnabled(val);
                          debugPrint(
                              'ConnectHiveSessionData.getChargeStartTime:\t${ConnectHiveSessionData.getChargeStartTime}');
                          debugPrint(
                              'ConnectHiveSessionData.getChargeEndTime:\t${ConnectHiveSessionData.getChargeEndTime}');
                        } else {
                          showAppSnackBar(
                            context: context,
                            title: 'Smart Charging',
                            response: {
                              'warningMsg':
                                  'Charge End should be greater than Charge Start',
                            },
                          );
                        }
                      } else {
                        if (_chargeStart == null && _chargeEnd == null) {
                          showAppSnackBar(
                            context: context,
                            title: 'Smart Charging',
                            response: {
                              'warningMsg':
                                  'Select Charge Start and Charge End',
                            },
                          );
                        } else if (_chargeStart == null) {
                          showAppSnackBar(
                            context: context,
                            title: 'Smart Charging',
                            response: {
                              'warningMsg': 'Select Charge Start',
                            },
                          );
                        } else if (_chargeEnd == null) {
                          showAppSnackBar(
                            context: context,
                            title: 'Smart Charging',
                            response: {
                              'warningMsg': 'Select Charge End',
                            },
                          );
                        }
                      }
                    } else {
                      // await ConnectHiveSessionData.deleteChargeStartTime;
                      // await ConnectHiveSessionData.deleteChargeEndTime;
                      ConnectHiveSessionData.setIsSmartChargingEnabled(val);
                    }
                  },
                );
              },
            ),
          ),

          /// Charge Start
          _buildChargeStartEndTile(
            title: 'Charge Start',
            trailing: _chargeStart!.format(context),
            callback: () async {
              await showTimePicker(
                context: context,
                initialTime: _chargeStart ?? TimeOfDay.now(),
              ).then((pickedTime) {
                if (pickedTime != null) {
                  ConnectHiveSessionData.setIsSmartChargingEnabled(false);
                  setState(() {
                    _chargeStart = pickedTime;
                    int compare = compareTime(
                        startTime: _chargeStart!, endTime: _chargeEnd!);
                    if (compare == 0 || compare > 0) {
                      _chargeEnd = pickedTime;
                    }
                  });
                }
              });
            },
          ),

          ///Charge End
          _buildChargeStartEndTile(
            title: 'Charge End',
            trailing: _chargeEnd!.format(context),
            callback: () async {
              await showTimePicker(
                context: context,
                initialTime: _chargeEnd ?? TimeOfDay.now(),
              ).then((pickedTime) {
                if (pickedTime != null) {
                  ConnectHiveSessionData.setIsSmartChargingEnabled(false);
                  setState(() {
                    _chargeEnd = pickedTime;
                    int compare = compareTime(
                        startTime: _chargeStart!, endTime: _chargeEnd!);
                    if (compare == 0 || compare > 0) {
                      _chargeStart = pickedTime;
                    }
                  });
                }
              });
            },
          ),
          SizedBox(
            height: 40,
            child: Divider(),
          ),
          Center(
            child: Tooltip(
              message: 'Logout',
              child: GestureDetector(
                onTap: () async {
                  _showLogOutDialog(context);
                },
                child: SizedBox(
                  width: 25.sp,
                  height: 25.sp,
                  child: SvgPicture.asset(
                    'assets/svg/power.svg',
                  ),
                ),
              ),
            ),
          ),
          Text("Logout",textAlign: TextAlign.center,),
          SizedBox(height: 10),
          _buildTCsAndPrivacy,
          SizedBox(height: 10,),
          MaterialButton(onPressed: (){
          
            showDialog(context: context,
            builder:(BuildContext context){
              return AlertDialog(
                title: Text('Warning: Destructive Action'),
              content: Wrap(
                children: [
                  Container(
                    child: Text('Are you sure you want to delete your GPEV Account?'),
                  ),
               
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          color: Colors.red,
                          onPressed: (){
                          deleteAccountApiCall()
                        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(respon))
                        )).whenComplete(() => 
                          Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider<SignInProvider>(
                            create: (context) => SignInProvider(),
                            builder: (context, _) => SignInScreen(),
                          ),
                        ),
                        (route) => false) 
                        );
                        },child: Text("Yes",style: TextStyle(color: Colors.white),),),
                        // VerticalDivider(
                        //   thickness: 10.0,
                        //   width: 7.0,
                        //   color: Colors.red,
                        // ),
                        MaterialButton(
                          color:Colors.green,
                          onPressed: (){
                          Navigator.of(context).pop();
                        },child: Text("No",style: TextStyle(color: Colors.white),),),
                      ],
                    ),
                  )
                ],
              ),
              );
            }
             
       
            );
          }, child: Text("Delete Account",
           
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.red,
        
        ),
          ),)
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget get _buildTCsAndPrivacy {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewScreen(
                    pdfTitle: 'Terms and Condition',
                    pdfLoadType: PdfLoadType.assets,
                    assetPath: 'assets/pdf/terms_and_conditions.pdf',
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xe3000000),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Text(
                padQuotes('T&Cs'),
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ),
          SizedBox(width: 5),
          Text(
            padQuotes('and'),
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewScreen(
                    pdfTitle: 'Privacy Policy',
                    pdfLoadType: PdfLoadType.assets,
                    assetPath: 'assets/pdf/Privacy_policy.pdf',
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xe3000000),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Text(
                padQuotes('Privacy'),
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildChargeStartEndTile({
    required String title,
    required String trailing,
    required GestureTapCallback callback,
  }) {
    return ListTile(
      // dense: true,
      contentPadding: EdgeInsets.only(left: 20.0),
      onTap: callback,
      leading: Text(
        padQuotes(title),
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      trailing: Text(
        padQuotes(trailing),
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  ListTile _buildPaymentType({
    required String title,
    required GestureTapCallback callback,
  }) {
    return ListTile(
      onTap: callback,
      contentPadding: EdgeInsets.only(left: 20.0),
      title: Text(
        padQuotes(title),
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      trailing: Container(
        padding: EdgeInsets.all(5.0),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 18.sp,
        ),
      ),
    );
  }

  Future _showLogOutDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Are you sure you want to Logout?',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await ConnectHiveSessionData.clearSessionData;
                  await ConnectHiveNetworkData.clearNetworkData;
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeNotifierProvider<SignInProvider>(
                          create: (context) => SignInProvider(),
                          builder: (context, _) => SignInScreen(),
                        ),
                      ),
                      (route) => false);
                },
                child: Text(
                  'YES',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Color(0xff519657),
                      ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'NO',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Color(0xff519657),
                      ),
                ),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);

    _switchNotifier.dispose();
    super.dispose();
  }
}