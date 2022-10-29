// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_providers/goCardLess/create_customer_bank_account_provider.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/connect_api.dart';
import '../../app_utils/connect/connect_goCardLess_payment_gateway.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';
import 'goCardLess_add_customer_bank_account_screen.dart';

class GoCardLessBankAccountListScreen extends StatefulWidget {
  final String customerId;

  const GoCardLessBankAccountListScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  _GoCardLessBankAccountListScreenState createState() =>
      _GoCardLessBankAccountListScreenState();
}

class _GoCardLessBankAccountListScreenState
    extends State<GoCardLessBankAccountListScreen> {
  final StreamController _streamController = StreamController();

  Future _getBankAccountList() async {
    String url = 'customer_bank_accounts';
    Map<String, dynamic> queryParameters = {
      'customer': widget.customerId,
      'enabled': 'true',
    };
    var res = await ConnectGoCardLessPaymentGateway.getCallMethod(
      url,
      queryParameters: queryParameters,
    );
    debugPrint('$url response:\t$res');
    Map? data;
    if (res.statusCode == 200) {
      data = json.decode(res.body);
    }
    if (!_streamController.isClosed) {
      _streamController.sink.add(data);
    }
  }

  Future _disableBankAccount({
    required String bankAccountId,
  }) async {
    String url = 'customer_bank_accounts/$bankAccountId/actions/disable';
    var res = await ConnectGoCardLessPaymentGateway.postCallMethod(url);
    Map? data;
    if (res.statusCode == 200) {
      data = json.decode(res.body);
    }
    return data;
  }

  Future _deleteBankAccountInServer({required String bankId}) async {
    String url = 'deleteBankDetails';
    url += '/$bankId';
    var res = await ConnectApi.deleteCallMethod(
      url,
    );
    debugPrint('$url Response:\t$res');
    return res;
  }

  _getDirectDebitDetails() async {
    var res = await AppApiCollection.getDetails(
        email: padQuotes(ConnectHiveSessionData.getEmail));
    if (res != null) {
      ConnectHiveSessionData.setDirectDebitDetails(res);
    }
    return res;
  }

  void _initialize() {
    _getDirectDebitDetails();
    _getBankAccountList();
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar,
              Expanded(
                child: _buildBody,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar => BuildAppBar(title: 'Bank Account');

  Widget get _buildBody {
    return StreamBuilder(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoader;
        } else if (snapshot.hasData) {
          Map<String, dynamic>? _data = snapshot.data as Map<String, dynamic>?;
          List _bankAccountList = _data!['customer_bank_accounts'];
          if (_bankAccountList.isEmpty) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('No Bank Accounts'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildAddBankAccount,
                ),
              ],
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            controller: ScrollController(),
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            itemCount: _bankAccountList.length,
            itemBuilder: (context, index) {
              return _buildCard(
                index: index,
                bankAccountDetails: _bankAccountList[index],
              );
            },
            separatorBuilder: (context, index) {
              return Container();
            },
          );
        }
        return Container();
      },
    );
  }

  Widget get _buildAddBankAccount => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChangeNotifierProvider<CreateCustomerBankAccountProvider>(
                  create: (context) => CreateCustomerBankAccountProvider(),
                  builder: (context, _) =>
                      GoCardLessAddCustomerBankAccountScreen(
                    customerId: widget.customerId,
                  ),
                ),
              ),
            ).then((value) {
              _getBankAccountList();
              _getDirectDebitDetails();
            });
          },
          child: Text(
            'Add Bank Account',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Colors.white,
                ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            shape: RoundedRectangleBorder(),
          ),
        ),
      );

  Future _showDisableBankAccountDialog() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Are you sure you want to disable the bank account ?',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, 'YES');
                },
                child: Text(
                  'YES',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'NO',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            ],
          );
        });
  }

  Widget _buildCard({
    required int index,
    required Map<String, dynamic> bankAccountDetails,
  }) {
    return Card(
      elevation: 5.0,
      child: ListTile(
        dense: true,
        title: Text(
          '******' + padQuotes(bankAccountDetails['account_number_ending']),
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text(
          padQuotes(bankAccountDetails['bank_name']),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_forever_outlined),
          onPressed: () async {
            var dialogResponse = await _showDisableBankAccountDialog();
            if (dialogResponse == 'YES') {
              Map? disableBankAccountResponse = await _disableBankAccount(
                bankAccountId: "${bankAccountDetails['id']}",
              );
              if (disableBankAccountResponse != null) {
                Map data = disableBankAccountResponse;
                if (data['customer_bank_accounts']['enabled'] == false) {
                  String bankId = padQuotes(ConnectHiveSessionData
                      .getDirectDebitDetails!.bankAccountList!
                      .where((element) =>
                          padQuotes(element.bankAccountId) ==
                          padQuotes(bankAccountDetails['id']))
                      .toList()
                      .first
                      .id);
                  await _deleteBankAccountInServer(bankId: bankId);
                }
              }
              _getBankAccountList();
            }
          },
        ),
      ),
    );
  }

  Widget get _buildLoader {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    _streamController.close();
    super.dispose();
  }
}
