// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';
// import 'package:intl/intl.dart';
// import 'package:stripe_payment/stripe_payment.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';

// import '../../app_utils/app_functions.dart';
// import '../../app_utils/connect/hive/connect_hive.dart';
// import '../../app_utils/widgets/widgets.dart';

// class StripeAddCardScreen extends StatefulWidget {
//   const StripeAddCardScreen({Key? key}) : super(key: key);

//   @override
//   _StripeAddCardScreenState createState() => _StripeAddCardScreenState();
// }

// class _StripeAddCardScreenState extends State<StripeAddCardScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String _cardNumber = '';
//   String _expiryDate = '';
//   String _cardHolderName = '';
//   String _cvvCode = '';
//   bool _isCvvFocused = false;
//   final ValueNotifier<bool> _pleaseWaitNotifier = ValueNotifier<bool>(false);

//   void _onCreditCardModelChange(CreditCardModel? creditCardModel) {
//     setState(() {
//       _cardNumber = creditCardModel!.cardNumber;
//       _expiryDate = creditCardModel.expiryDate;
//       _cardHolderName = creditCardModel.cardHolderName;
//       _cvvCode = creditCardModel.cvvCode;
//       _isCvvFocused = creditCardModel.isCvvFocused;
//     });
//   }

//   _showSnackBar({required String message}) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     debugPrintInit(widget.runtimeType);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle.dark.copyWith(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.dark,
//         ),
//         child: SafeArea(
//           child: HideKeyboard(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildAppBar,
//                 Expanded(child: _buildBody),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget get _buildAppBar => BuildAppBar(title: 'Add Card');

//   Widget get _buildBody {
//     return ListView(
//       children: [
//         CreditCardWidget(
//           cardNumber: _cardNumber,
//           expiryDate: _expiryDate,
//           cardHolderName: _cardHolderName,
//           cvvCode: _cvvCode,
//           showBackView: _isCvvFocused,
//           obscureCardNumber: false,
//           obscureCardCvv: true,
//         ),
//         CreditCardForm(
//           formKey: _formKey,
//           obscureCvv: true,
//           obscureNumber: false,
//           cardNumber: _cardNumber,
//           cvvCode: _cvvCode,
//           cardHolderName: _cardHolderName,
//           expiryDate: _expiryDate,
//           themeColor: Colors.blue,
//           cardNumberDecoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Card Number',
//             hintText: 'XXXX XXXX XXXX XXXX',
//           ),
//           expiryDateDecoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Expiry Date',
//             hintText: 'XX/XX',
//           ),
//           cvvCodeDecoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'CVV Code',
//             hintText: 'XXX',
//           ),
//           cardHolderDecoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Card Holder Name',
//           ),
//           onCreditCardModelChange: _onCreditCardModelChange,
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
//           child: ValueListenableBuilder(
//             valueListenable: _pleaseWaitNotifier,
//             builder: (context, notifierValue, _) {
//               if (notifierValue == true) {
//                 return _buildPleaseWaitButton;
//               }
//               return _buildAddCardButton;
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget get _buildAddCardButton {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         padding: EdgeInsets.symmetric(vertical: 10.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         primary: Theme.of(context).primaryColor,
//         textStyle: Theme.of(context)
//             .textTheme
//             .headline1!
//             .copyWith(color: Colors.white),
//       ),
//       child: const Text('Add Card'),
//       onPressed: () async {
//         HideKeyboard.hide(context);
//         if (_formKey.currentState!.validate()) {
//           try {
//             _pleaseWaitNotifier.value = true;
//             await StripePayment.createPaymentMethod(
//               PaymentMethodRequest(
//                 card: CreditCard(
//                   number: _cardNumber,
//                   name: _cardHolderName,
//                   expMonth: int.parse(_expiryDate.split('/')[0]),
//                   expYear: int.parse(_expiryDate.split('/')[1]),
//                   cvc: _cvvCode,
//                 ),
//               ),
//             ).then((value) {
//               debugPrint('value:\t${value.toJson()}');
//               ConnectHiveSessionData.setCardDetails(
//                 creditCard: CreditCard(
//                   number: padQuotes(_cardNumber),
//                   name: padQuotes(_cardHolderName),
//                   expMonth: int.parse(_expiryDate.split('/')[0]),
//                   expYear: int.parse(_expiryDate.split('/')[1]),
//                   cvc: padQuotes(_cvvCode),
//                   brand:
//                       toBeginningOfSentenceCase(padQuotes(value.card!.brand)),
//                   funding:
//                       toBeginningOfSentenceCase(padQuotes(value.card!.funding)),
//                   last4: value.card!.last4,
//                 ),
//               );
//               Navigator.pop(context, {
//                 'successMsg': 'Card added successfully',
//               });
//             });
//             _pleaseWaitNotifier.value = false;
//           } on PlatformException catch (e) {
//             _pleaseWaitNotifier.value = false;
//             debugPrint('PlatformException:\t${e.toString()}');
//             _showSnackBar(message: '${e.message}');
//           } catch (e) {
//             _pleaseWaitNotifier.value = false;
//             debugPrint('Exception:\t$e');
//           }
//         }
//       },
//     );
//   }

//   Widget get _buildPleaseWaitButton => IgnorePointer(
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.symmetric(vertical: 10.0),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             primary: Theme.of(context).primaryColor,
//             textStyle: Theme.of(context).textTheme.headline1!.copyWith(
//                   color: Colors.white,
//                 ),
//           ),
//           child: Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   alignment: Alignment.center,
//                   child: Text(
//                     'Please Wait',
//                     textAlign: TextAlign.left,
//                     style: Theme.of(context).textTheme.headline1!.copyWith(
//                           color: Colors.white,
//                         ),
//                   ),
//                 ),
//                 SizedBox(width: 20),
//                 SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation(Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           onPressed: () {},
//         ),
//       );

//   @override
//   void dispose() {
//     debugPrintDispose(widget.runtimeType);
//     _pleaseWaitNotifier.dispose();
//     super.dispose();
//   }
// }
