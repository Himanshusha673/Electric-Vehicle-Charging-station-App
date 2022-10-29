import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import './app_screens/splash_screen.dart';
import './app_utils/app_theme.dart';
import 'app_utils/app_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_YsmwEHsYk0mEtTwCPkvR24Ec00LKdccQNT';
  await Stripe.instance.applySettings();
  runApp(GreenPointEVApp());
}

class GreenPointEVApp extends StatelessWidget {
  const GreenPointEVApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          home: SplashScreen(),
        );
      },
    );
  }
}
