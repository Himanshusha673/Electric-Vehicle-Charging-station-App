import 'dart:convert';

DirectDebitDetailsModel directDebitDetailsModelFromJson(String str) =>
    DirectDebitDetailsModel.fromJson(json.decode(str));

String directDebitDetailsModelToJson(DirectDebitDetailsModel data) =>
    json.encode(data.toJson());

class DirectDebitDetailsModel {
  DirectDebitDetailsModel({
    this.customerId,
    this.creditorId,
    this.bankAccountList,
  });

  String? customerId;
  String? creditorId;
  List<BankAccountList>? bankAccountList;

  factory DirectDebitDetailsModel.fromJson(Map<String, dynamic> json) =>
      DirectDebitDetailsModel(
        customerId: json['customer_id'],
        creditorId: json['creditor_id'],
        bankAccountList: List<BankAccountList>.from(
            json['bank_account_list'].map((x) => BankAccountList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'creditor_id': creditorId,
        'bank_account_list':
            List<dynamic>.from(bankAccountList!.map((x) => x.toJson())),
      };
}

class BankAccountList {
  BankAccountList({
    this.id,
    this.bankAccountId,
  });

  int? id;
  String? bankAccountId;

  factory BankAccountList.fromJson(Map<String, dynamic> json) =>
      BankAccountList(
        id: json['id'],
        bankAccountId: json['bank_account_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bank_account_id': bankAccountId,
      };
}
