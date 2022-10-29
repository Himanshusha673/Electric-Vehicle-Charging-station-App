import 'dart:math' as math;

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'app_constants.dart';
import 'app_enums.dart';

export 'package:sizer/sizer.dart';

export 'app_constants.dart';
export 'app_enums.dart';

/// Get Index By Home Bottom Navigation Item
int getIndexByHomeBottomNavigationItem(HomeBottomNavigationItem? item) {
  switch (item) {
    case HomeBottomNavigationItem.home:
      return 0;
    case HomeBottomNavigationItem.history:
      return 1;
    case HomeBottomNavigationItem.dashboard:
      return 3;
    case HomeBottomNavigationItem.settings:
      return 4;
    default:
      return 0;
  }
}

/// Set Preferred Orientations
setPreferredOrientations({
  List<DeviceOrientation>? deviceOrientation,
  Orientation? orientation,
}) async {
  assert(deviceOrientation == null || orientation == null,
      'Cannot provide both deviceOrientation and orientation.');
  if (deviceOrientation != null && deviceOrientation.isNotEmpty) {
    SystemChrome.setPreferredOrientations(deviceOrientation);
  } else if (orientation != null) {
    if (orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

bool isValidEmail(input) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  return (regex.hasMatch(input.toString().trim()));
}

String padQuotes(input) {
  if (input == null || input.toString() == 'null') {
    return '';
  } else {
    return input.toString().trim();
  }
}

String cNumeric(input) {
  if (input == null ||
      input.toString() == 'null' ||
      int.tryParse(input.toString()) == null) {
    return '0';
  } else {
    return input.toString().trim();
  }
}

int numeric(input) {
  if (input == null ||
      input.toString() == 'null' ||
      int.tryParse(input.toString()) == null) {
    return 0;
  } else {
    return int.parse(input.toString().trim());
  }
}

bool isNumeric(input) {
  if (int.tryParse(input.toString()) != null) {
    return true;
  } else {
    return false;
  }
}

String numberFormat(input) {
  if (input == null ||
      input.toString() == 'null' ||
      int.tryParse(input.toString()) == null) {
    return '--';
  }
  return NumberFormat.compact().format(int.parse(input.toString()));
}

/// 6 digit random number
int generateRandomNumber() {
  return math.Random().nextInt(900000) + 100000;
}

///format Duration i.e, hh:mm:ss
String formatDuration(Duration duration) {
  return duration.toString().split('.').first.padLeft(8, '0');
}

/// TimeOfDay to time i.e,HH:mm:ss
String timeOfDayToTime(TimeOfDay timeOfDay) {
  DateTime now = DateTime.now();
  return DateFormat('HH:mm:ss')
      .format(DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      ))
      .toString()
      .trim();
}

TimeOfDay timeToTimeOfDay(String time) {
  DateTime dateTime =
      DateTime.parse("${DateTime.now().toString().split(" ")[0]} " + time);
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

String getAuthorityFromUrl(String url, {Pattern pattern = 'https://'}) {
  return url.replaceFirst(pattern, '').split('/')[0];
}

int timeToSecond(String time) {
  TimeOfDay timeOfDay = timeToTimeOfDay(time);
  int second = (timeOfDay.hour * 3600) + (timeOfDay.minute * 60);
  return second;
}

double getGraphPoints({totalCount, value}) {
  // debugPrint("totalCount: $totalCount \tvalue: $value");
  if (numeric(totalCount) == 0) {
    return 0.0;
  }
  // debugPrint("getGraphPoints:\t${roundDouble(((double.parse(padQuotes(value)) * 5) / numeric(totalCount)).toDouble(), 2)}");
  return roundDouble(
      ((double.parse(padQuotes(value)) * 5) / numeric(totalCount)).toDouble(),
      2);
}

double roundDouble(dynamic value, [int places = 2]) {
  num mod = math.pow(10.00, places);
  return ((double.parse(padQuotes(value)) * mod).round().toDouble() / mod);
}

String convertToDistance(input) {
  if (input == null && double.tryParse(input.toString()) == null) {
    return '0.0 m';
  } else {
    double distance = roundDouble(double.parse(input.toString()) / 1000);
    if (double.parse(input.toString()) > 1000) {
      return '$distance km';
    } else {
      return '$distance m';
    }
  }
}

showAppSnackBar({
  required BuildContext context,
  String? title,
  required Map? response,
  Duration? duration,
  void Function(Flushbar<dynamic>)? onTap,
}) {
  Color? leftBarIndicatorColor;
  String? name;
  String? message;
  bool? repeat;
  duration ??= Duration(seconds: 4);

  if (response != null && response.containsKey('successMsg')) {
    leftBarIndicatorColor = Colors.green;
    name = 'assets/lotties/success.json';
    message = response['successMsg'].toString().trim();
    repeat = false;
  } else if (response != null && response.containsKey('errorMsg')) {
    leftBarIndicatorColor = Colors.redAccent;
    name = 'assets/lotties/error.json';
    message = response['errorMsg'].toString().trim();
    repeat = false;
  } else if (response != null && response.containsKey('warningMsg')) {
    leftBarIndicatorColor = Colors.orangeAccent;
    name = 'assets/lotties/warning.json';
    message = response['warningMsg'].toString().trim();
    repeat = true;
  } else {}

  Flushbar(
    leftBarIndicatorColor: leftBarIndicatorColor,
    icon: Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      child: LottieBuilder.asset(
        '$name',
        fit: BoxFit.cover,
        repeat: repeat,
      ),
    ),
    duration: duration,
    title: title,
    message: message,
    onTap: onTap,
  ).show(context);
}

///Check Long Date Format
bool isLongDateFormat(date) {
  if (DateTime.tryParse('$date') != null) {
    return true;
  } else {
    return false;
  }
}

///End time greater than Start time
bool isEndTimeGreaterThanStartTime(
    {required String startTime, required String endTime}) {
  if (isLongDateFormat(startTime) && isLongDateFormat(endTime)) {
    if (DateTime.parse(endTime).isAfter(DateTime.parse(startTime))) {
      return true;
    }
    return false;
  } else {
    return false;
  }
}

bool isDateTimeLessThanCurrentDateTime({required String dateTime}) {
  if (isLongDateFormat(dateTime)) {
    DateTime now = DateTime.now();
    return DateTime.parse(dateTime).isBefore(now);
  } else {
    return false;
  }
}

bool isDateTimeGreaterThanCurrentDateTime({required String dateTime}) {
  if (isLongDateFormat(dateTime)) {
    DateTime now = DateTime.now();
    return DateTime.parse(dateTime).isAfter(now);
  } else {
    return false;
  }
}

/// compare time
///
/// [startTime] == [endTime] => 0
///
/// [startTime] < [endTime] => -1
///
/// [startTime] > [endTime] => 1
int compareTime({
  required TimeOfDay startTime,
  required TimeOfDay endTime,
}) {
  DateTime now = DateTime.now();
  DateTime start = DateTime(
    now.year,
    now.month,
    now.day,
    startTime.hour,
    startTime.minute,
  );
  DateTime end = DateTime(
    now.year,
    now.month,
    now.day,
    endTime.hour,
    endTime.minute,
  );
  return start.compareTo(end);
}

///convert To Company Date Format
String convertToCompanyDateFormat({
  required String pattern, //MM/dd/yyyy
  required String date,
}) {
  if (isLongDateFormat(date)) {
    return DateFormat(pattern).format(DateTime.parse(padQuotes(date)));
  } else {
    return '';
  }
}

///Calculate Duration (i.e, 00:00:00)
String calculateDuration({
  required String startTime,
  required String endTime,
}) {
  int hours;
  int minutes;
  int seconds;
  String duration;
  seconds =
      DateTime.parse(endTime).difference(DateTime.parse(startTime)).inSeconds;
  int n = seconds;
  n = n % (24 * 3600);
  hours = n ~/ 3600;
  n %= 3600;
  minutes = n ~/ 60;
  n %= 60;
  seconds = n;
  // duration = "${(hours.toString().length > 1)  ? '' : "0$hours"}h:"+
  // "${(minutes.toString().length > 1) ? minutes : "0$minutes"}m:"+"${(seconds.toString().length > 1) ? seconds : "0$seconds"}s";

  // duration =(hours!=0)? "${(hours.toString().length > 1)  ? hours : "0$hours"}h:":
      
  //     "${(minutes.toString().length > 1) ? minutes : "0$minutes"}m"
  //     ':'
  //     "${(seconds.toString().length > 1) ? seconds : "0$seconds"}s";
  if(hours==0){
    duration = 
  "${(minutes.toString().length > 1) ? minutes : "0$minutes"}m";
  }
  else{
    duration = "${(hours.toString().length > 1)  ? '' : "0$hours"}h:"+
  "${(minutes.toString().length > 1) ? minutes : "0$minutes"}m";
  }
  return duration;
}

Future showLocationPermissionDialog({
  required BuildContext context,
  required LocationPermission locationPermission,
}) async {
  String body =
      'We need access to your location to be able to find stations near you,'
      ' allow ${AppConstants.appName} access to your location. ';
  switch (locationPermission) {
    case LocationPermission.deniedForever:
      body = body + ' Tap Settings > Permissions, and turn Location on.';
      break;
    default:
      break;
  }

  return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  height: 40,
                  width: 40,
                  child: LottieBuilder.asset(
                    'assets/lotties/warning.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Text(
                  'Access to location data required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        textStyle: Theme.of(context).textTheme.bodyText2,
                      ),
                      child: Text('NOT NOW'),
                    ),
                    if (locationPermission == LocationPermission.denied)
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context, 'continue');
                        },
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          textStyle: Theme.of(context).textTheme.bodyText2,
                        ),
                        child: Text('CONTINUE'),
                      ),
                    if (locationPermission == LocationPermission.deniedForever)
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context, 'settings');
                        },
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          textStyle: Theme.of(context).textTheme.bodyText2,
                        ),
                        child: Text('SETTINGS'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}

Future showLocationEnableDialog({
  required BuildContext context,
}) async {
  String body =
      'We need access to your location to be able to find stations near you,'
      ' allow ${AppConstants.appName} access to your location. ';

  return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  height: 40,
                  width: 40,
                  child: LottieBuilder.asset(
                    'assets/lotties/warning.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Text(
                  'Enable Location?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'skip');
                      },
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        textStyle: Theme.of(context).textTheme.bodyText2,
                      ),
                      child: Text('Skip'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context, 'continue');
                      },
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        textStyle: Theme.of(context).textTheme.bodyText2,
                      ),
                      child: Text('CONTINUE'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}

void debugPrintInit(className) {
  debugPrint('\x1B[1;3;95m---------- $className init ----------\x1B[0m');
}

void debugPrintDispose(className) {
  debugPrint('\x1B[1;3;93m---------- $className dispose ----------\x1B[0m');
}