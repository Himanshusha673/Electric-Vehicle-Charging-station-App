import 'dart:convert';

ChargeBoxDetailsModel chargeBoxDetailsModelFromJson(String str) =>
    ChargeBoxDetailsModel.fromJson(json.decode(str));

String chargeBoxDetailsModelToJson(ChargeBoxDetailsModel data) =>
    json.encode(data.toJson());

class ChargeBoxDetailsModel {
  ChargeBoxDetailsModel({
    this.chargeBoxId,
    this.connectorDescription,
    this.longitude,
    this.latitude,
  });

  dynamic chargeBoxId;
  dynamic connectorDescription;
  dynamic latitude;
  dynamic longitude;

  factory ChargeBoxDetailsModel.fromJson(Map<String, dynamic> json) =>
      ChargeBoxDetailsModel(
        chargeBoxId: json['charge_box_id'],
        connectorDescription: json['connector_description'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );

  Map<String, dynamic> toJson() => {
        'charge_box_id': chargeBoxId,
        'connector_description': connectorDescription,
        'latitude': latitude,
        'longitude': longitude,
      };
}
