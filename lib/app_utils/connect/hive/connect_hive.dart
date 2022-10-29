library app_utils.connect.hive;

import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';

// import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../app_models/charging_scheduled_details_model.dart' as cschdm;
import '../../../app_models/charging_started_details_model.dart' as cstadm;
import '../../../app_models/direct_debit_details_model.dart' as dddm;

part 'boxes/connect_hive_network_data.dart';
part 'boxes/connect_hive_session_data.dart';

class ConnectHive {
  ///* --------------- Box name --------------- *///
  static const String boxNameSessionData = 'sessionData';
  static const String boxNameNetworkData = 'networkData';

  ///* --------------- initialize Box --------------- *///
  static final Box boxSessionData = Hive.box(boxNameSessionData);
  static final Box boxNetworkData = Hive.box(boxNameNetworkData);
}