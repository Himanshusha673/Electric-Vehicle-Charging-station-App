import 'dart:convert';

import '../app_utils/app_enums.dart';
import 'chargeBox_details_model.dart';

ChargingScheduledDetailsModel chargingScheduledDetailsModelFromJson(
        String str) =>
    ChargingScheduledDetailsModel.fromJson(json.decode(str));

String chargingScheduledDetailsModelToJson(
        ChargingScheduledDetailsModel data) =>
    json.encode(data.toJson());

class ChargingScheduledDetailsModel {
  ChargingScheduledDetailsModel({
    this.chargeBoxDetails,
    this.connectorId,
    this.transactionId,
    this.idTag,
    this.paymentMethodType,
    this.date,
    this.startTime,
    this.endTime,
  });

  ChargeBoxDetailsModel? chargeBoxDetails;
  String? connectorId;
  String? transactionId;
  String? idTag;
  PaymentMethodType? paymentMethodType;
  String? date;
  String? startTime;
  String? endTime;

  factory ChargingScheduledDetailsModel.fromJson(Map<String, dynamic> json) =>
      ChargingScheduledDetailsModel(
        chargeBoxDetails:
            ChargeBoxDetailsModel.fromJson(json['chargeBoxDetails']),
        connectorId: json['connectorId'],
        transactionId: json['transactionId'],
        idTag: json['idTag'],
        paymentMethodType:
            PaymentMethodType.values.asNameMap()[json['paymentMethodType']],
        date: json['date'],
        startTime: json['startTime'],
        endTime: json['endTime'],
      );

  Map<String, dynamic> toJson() => {
        'chargeBoxDetails': chargeBoxDetails!.toJson(),
        'connectorId': connectorId,
        'transactionId': transactionId,
        'idTag': idTag,
        'paymentMethodType': paymentMethodType?.name,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
      };
}
