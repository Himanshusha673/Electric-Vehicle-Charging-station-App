import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../app_providers/on_boarding_provider.dart';
import '../app_screens/main_screen.dart';
import '../flutter_StripeFiles/connect_strip_payment1.dart';
import 'onBoarding/sign_in_screen.dart';
import '../app_utils/app_functions.dart';
// import '../app_utils/connect/connect_stripe_payment_gateway.dart';
import '../app_utils/connect/hive/connect_hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _goToNextScreen() {
    Future.delayed(
      Duration(
        seconds: 3,
      ),
      () async {
        if (padQuotes(ConnectHiveSessionData.getToken).isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<SignInProvider>(
                create: (context) => SignInProvider(),
                builder: (context, _) => SignInScreen(),
              ),
            ),
          );
        }
      },
    );
  }

  void _initialize() async {
    setPreferredOrientations(orientation: Orientation.portrait);
    await Hive.initFlutter();
    await ConnectHiveSessionData.initialize();
    await ConnectHiveNetworkData.initialize();
    ConnectStripePaymentGateway.init();
    _goToNextScreen();
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    setPreferredOrientations(orientation: Orientation.portrait);
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/splashscreen_background.png',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    super.dispose();
  }
}
