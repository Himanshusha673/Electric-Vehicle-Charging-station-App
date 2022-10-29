import 'dart:convert';

import '../app_utils/app_enums.dart';

import 'chargeBox_details_model.dart';

ChargingStartedDetailsModel chargingStartedDetailsModelFromJson(String str) =>
    ChargingStartedDetailsModel.fromJson(json.decode(str));

String chargingStartedDetailsModelToJson(ChargingStartedDetailsModel data) =>
    json.encode(data.toJson());

class ChargingStartedDetailsModel {
  ChargingStartedDetailsModel({
    this.chargeBoxDetails,
    this.connectorId,
    this.transactionId,
    this.idTag,
    this.paymentMethodType,
  });

  ChargeBoxDetailsModel? chargeBoxDetails;
  String? connectorId;
  String? transactionId;
  String? idTag;
  PaymentMethodType? paymentMethodType;

  factory ChargingStartedDetailsModel.fromJson(Map<String, dynamic> json) =>
      ChargingStartedDetailsModel(
        chargeBoxDetails:
            ChargeBoxDetailsModel.fromJson(json['chargeBoxDetails']),
        connectorId: json['connectorId'],
        transactionId: json['transactionId'],
        idTag: json['idTag'],
        paymentMethodType:
            PaymentMethodType.values.asNameMap()[json['paymentMethodType']],
      );

  Map<String, dynamic> toJson() => {
        'chargeBoxDetails': chargeBoxDetails!.toJson(),
        'connectorId': connectorId,
        'transactionId': transactionId,
        'idTag': idTag,
        'paymentMethodType': paymentMethodType?.name,
      };
}
