import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import '../../app_providers/settings_provider.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/connect_api.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/build_app_bar.dart';
import '../settings/settings_screen.dart';
import 'stripe_add_card_screen.dart';
import 'package:http/http.dart' as http;

class StripeCardListScreen extends StatefulWidget {
  const StripeCardListScreen({Key? key}) : super(key: key);

  @override
  _StripeCardListScreenState createState() => _StripeCardListScreenState();
}

class _StripeCardListScreenState extends State<StripeCardListScreen> {
  final StreamController _streamController = StreamController();

  Future _getCardDetails() async {
    Map<String, dynamic>? creditCardData;
    CardDetails? creditCard = ConnectHiveSessionData.getCardDetails;
    if (creditCard != null) {
      creditCardData = creditCard.toJson();
    }
    if (!_streamController.isClosed) {
      _streamController.sink.add(creditCardData);
    }
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    // buildCard();
    super.initState();
    _getCardDetails();
  }

Future deleteCardDetailsApi() async {
    var headers = {
  'Content-Type': 'application/json'
};
var request = http.Request('POST', Uri.parse('https://api.greenpointev.com/inindia.tech/public/api/app/card/delete/${ConnectHiveSessionData.getEmail}'));
request.body = json.encode({
       'ref_user': ConnectHiveSessionData.getEmail,
     

});
request.headers.addAll(headers);

http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
  log('Delete card');
  log(request.body);
  log(await response.stream.bytesToString());
  
}
else {
  print(response.reasonPhrase);
}
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar,
              Expanded(
                child: buildCard(),
                // child: _buildBody,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar => BuildAppBar(title: 'Cards');

  Widget get _buildBody {
    return StreamBuilder(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            Map<String, dynamic>? _data = snapshot.data as Map<String, dynamic>?;
          CardDetails? _creditCardData;
           log("On reload :"+ConnectHive.boxSessionData.get("cardDetails")["number"].toString());
          return _buildLoader;

        } else if (snapshot.connectionState == ConnectionState.active) {
          Map<String, dynamic>? _data = snapshot.data as Map<String, dynamic>?;
          CardDetails? _creditCardData;
            log("Getting : "+_data.toString());
          if (_data != null) {
            
            _creditCardData = CardDetails.fromJson(_data);
          }
          if (_creditCardData != null) {
            return ListView(
              children: [
                // _buildCard(creditCard: _creditCardData),
              ],
            );
          }
          return _buildNoNewCards;
        }
        return Container();
      },
    );
  }

  Widget get _buildNoNewCards {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('No New Cards'),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildAddCard,
        ),
      ],
    );
  }

  Widget get _buildAddCard => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StripeAddCardScreen(),
              ),
            );
            _getCardDetails();
          },
          child: Text(
            '+ Add Card',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Colors.white,
                ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            shape: RoundedRectangleBorder(),
          ),
        ),
      );

      //! Build Card

      Widget buildCard(){
        
        if( ConnectHive.boxSessionData.get('cardDetails')!=null){

        return GestureDetector(
          onLongPress: () async{
                  try {
          await _showDisableBankAccountDialog(context).then((value) {
            debugPrint('value:\t$value');
            if (value == true) {
              _getCardDetails();
            }
          });
        } catch (e) {
          debugPrint('Exception:\t$e');
        }
          },
          child: CreditCardWidget(
            cardNumber:  ConnectHive.boxSessionData.get('cardDetails')['number'].toString(),
             expiryDate:  ConnectHive.boxSessionData.get('cardDetails')['expirationMonth'].toString()+'/' +ConnectHive.boxSessionData.get('cardDetails')['expirationYear'].toString(), 
             cardHolderName: "*",
              cvvCode: ConnectHive.boxSessionData.get('cardDetails')['cvc'].toString(),
           showBackView: false,
            
          obscureCardCvv: true,
          obscureCardNumber: true,
           ),
        );
        }
        else{
          return _buildNoNewCards;
        }
      }

  // Widget _buildCard({required CardDetails creditCard}) {
  //   return GestureDetector(
  //     onLongPress: () async {
  //       try {
  //         await _showDisableBankAccountDialog(context).then((value) {
  //           debugPrint('value:\t$value');
  //           if (value == true) {
  //             _getCardDetails();
  //           }
  //         });
  //       } catch (e) {
  //         debugPrint('Exception:\t$e');
  //       }
  //     },
  //     child: CreditCardWidget(
  //       cardNumber: '${creditCard.number}',
  //       expiryDate: '${creditCard.expirationMonth}' '/' '${creditCard.expirationYear}',
  //       cardHolderName: '${creditCard.cvc}',
  //       cvvCode: '${creditCard.cvc}',
  //       showBackView: false,
  //       obscureCardCvv: true,
  //       obscureCardNumber: true,
  //     ),
  //   );
  // }

  Future<bool> _showDisableBankAccountDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Are you sure you want to delete the card ?',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await ConnectHiveSessionData.deleteCardDetails;
                  // deleteCardDetailsApi();
                   Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                  create: (context) => SettingsProvider(),
                                  builder: (context, child) => child!,
                                  child: SettingsScreen()),
                            ),
                          );
                  // Navigator.pop(context, true);
                },
                child: Text(
                  'YES',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
              TextButton(
                onPressed: ()  {
                  Navigator.pop(context, false);
                },
                child: Text(
                  'NO',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            ],
          );
        });
  }

  Widget get _buildLoader {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    _streamController.close();
    super.dispose();
  }
}