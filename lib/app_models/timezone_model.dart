import 'dart:convert';

TimeZoneResponseModel timeZoneModelFromJson(String str) =>
    TimeZoneResponseModel.fromJson(json.decode(str));

String timeZoneModelModelToJson(TimeZoneResponseModel data) =>
    json.encode(data.toJson());

class TimeZoneResponseModel {
  String? datetime;
  String? timezoneName;
  String? timezoneLocation;
  String? timezoneAbbreviation;
  int? gmtOffset;
  bool? isDst;
  String? requestedLocation;
  String? latitude;
  String? longitude;

  TimeZoneResponseModel(
      {this.datetime,
      this.timezoneName,
      this.timezoneLocation,
      this.timezoneAbbreviation,
      this.gmtOffset,
      this.isDst,
      this.requestedLocation,
      this.latitude,
      this.longitude});

  TimeZoneResponseModel.fromJson(Map<String, dynamic> json) {
    datetime = json['datetime'];
    timezoneName = json['timezone_name'];
    timezoneLocation = json['timezone_location'];
    timezoneAbbreviation = json['timezone_abbreviation'];
    gmtOffset = json['gmt_offset'];
    isDst = json['is_dst'];
    requestedLocation = json['requested_location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['datetime'] = datetime;
    data['timezone_name'] = timezoneName;
    data['timezone_location'] = timezoneLocation;
    data['timezone_abbreviation'] = timezoneAbbreviation;
    data['gmt_offset'] = gmtOffset;
    data['is_dst'] = isDst;
    data['requested_location'] = requestedLocation;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
