import 'app_functions.dart';

class AppConstants {
  static const String appName = 'GreenPoint EV';
  static const String firebaseServerKey = '';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.GreenPointEV.Ltd';
  static const String appStoreUrl =
      'https://apps.apple.com/us/app/greenpoint-ev/id1553259119';

  static const Set<String> testersEmailLists = {
    'rdcummings0@gmail.com',
    'user1@gmail.com',
  };
  static const String abstractApiKey = '7c3998d5158f40b8b1b1fd332de268ea';

// testing api key for getting timezone added by Himanshu  its trial beased
  //static const String abstractApiKey = 'bed9558530ca49b09ea9da00718f4831';

  static const PayterServersType payterServersType = PayterServersType.test;

  static const StripeAccountType stripeAccountType = StripeAccountType.live;
}
