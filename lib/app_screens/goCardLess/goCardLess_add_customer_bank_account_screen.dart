// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../app_providers/goCardLess/create_customer_bank_account_provider.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/connect_goCardLess_payment_gateway.dart';
import '../../app_utils/widgets/widgets.dart';

class GoCardLessAddCustomerBankAccountScreen extends StatefulWidget {
  final String? customerId;

  const GoCardLessAddCustomerBankAccountScreen({
    Key? key,
    @required this.customerId,
  }) : super(key: key);

  @override
  _GoCardLessAddCustomerBankAccountScreenState createState() =>
      _GoCardLessAddCustomerBankAccountScreenState();
}

class _GoCardLessAddCustomerBankAccountScreenState
    extends State<GoCardLessAddCustomerBankAccountScreen> {
  int _initialFlag = 0;

  ///Controller
  final TextEditingController _accountNumber = TextEditingController();
  final TextEditingController _branchCode = TextEditingController();
  final TextEditingController _accountHolderName = TextEditingController();

  ///Dropdown Id
  String? _countryId;

  ///Dropdown List
  List _countryList = [];

  final ValueNotifier<bool> _pleaseWaitNotifier = ValueNotifier<bool>(false);

  Future<Response> _createCustomerBankAccount(Map bankAccountData) async {
    _pleaseWaitNotifier.value = true;
    String url = 'customer_bank_accounts';
    var res = await ConnectGoCardLessPaymentGateway.postCallMethod(
      url,
      body: bankAccountData,
    );
    debugPrint('$url Response:\t$res');
    return res;
  }

  Future _addBankAccount({
    required String customerBankAccountId,
  }) async {
    var res = await AppApiCollection.addBankDetails(
      customerId: widget.customerId,
      customerBankAccountId: customerBankAccountId,
    );
    return res;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();

    /// Initializing Dropdown
    Provider.of<CreateCustomerBankAccountProvider>(context, listen: false)
        .countryData(notify: true);
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
          child: Consumer<CreateCustomerBankAccountProvider>(
            builder: (context, service, _) {
              _countryList = service.country;
              if (_countryList.isNotEmpty && _initialFlag == 0) {
                _countryId = _countryList[0]['alpha2Code'].toString();
                _initialFlag++;
              }
              return HideKeyboard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar,
                    Expanded(child: _buildBody(service: service)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar => BuildAppBar(
        title: 'Add Bank Account',
      );

  Widget _buildBody({
    required CreateCustomerBankAccountProvider service,
  }) {
    return ListView(
      shrinkWrap: true,
      controller: ScrollController(),
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      children: <Widget>[
        BuildTextFormField(
          title: 'Account Number',
          controller: _accountNumber,
          errorText: service.accountNumberValidation,
        ),
        BuildTextFormField(
          title: 'Branch Code',
          controller: _branchCode,
          errorText: service.branchCodeValidation,
        ),
        BuildTextFormField(
          title: 'Account Holder Name',
          controller: _accountHolderName,
          errorText: service.accountHolderNameValidation,
        ),
        BuildCountryDropdown(
          title: 'Country',
          initialValue: _countryId,
          listData: _countryList,
          onChange: (val) {
            _countryId = val.value;
          },
          errorText: service.countryCodeValidation,
        ),
        SizedBox(height: 20),
        ValueListenableBuilder(
          valueListenable: _pleaseWaitNotifier,
          builder: (context, notifierValue, _) {
            if (notifierValue == true) {
              return _buildPleaseWaitButton;
            }
            return _buildAddBankAccountButton;
          },
        ),
      ],
    );
  }

  Widget get _buildAddBankAccountButton => InkWell(
        onTap: () async {
          HideKeyboard.hide(context);
          Map bankAccountData = {
            'customer_bank_accounts': {
              'account_number': padQuotes(_accountNumber.text),
              'branch_code': padQuotes(_branchCode.text),
              'account_holder_name': padQuotes(_accountHolderName.text),
              'country_code': padQuotes(_countryId),
              'links': {
                'customer': padQuotes(widget.customerId),
              }
            }
          };
          await _createCustomerBankAccount(bankAccountData).then(
            (dynamic res) async {
              if (res != null) {
                int _statusCode = res.statusCode;
                Map _data;
                switch (_statusCode) {
                  case 201:
                    _data = json.decode(res.body);
                    Provider.of<CreateCustomerBankAccountProvider>(context,
                            listen: false)
                        .createCustomerBankAccountValidationReset(
                      notify: true,
                    );
                    Map customerBankAccount = _data['customer_bank_accounts'];
                    Map? addBankAccountResponse = await _addBankAccount(
                      customerBankAccountId:
                          padQuotes(customerBankAccount['id']),
                    );
                    if (addBankAccountResponse != null &&
                        addBankAccountResponse.containsKey('successMsg')) {
                      _pleaseWaitNotifier.value = false;
                      Navigator.pop(context, res);
                    }

                    break;
                  case 409:
                    _pleaseWaitNotifier.value = false;
                    _data = json.decode(res.body);
                    Map error = _data['error'];
                    String message = padQuotes(error['message']);
                    showAppSnackBar(
                      context: context,
                      title: 'Create Bank Account',
                      response: {
                        'errorMsg': message,
                      },
                    );
                    break;
                  case 422:
                    _pleaseWaitNotifier.value = false;
                    _data = json.decode(res.body);
                    Provider.of<CreateCustomerBankAccountProvider>(context,
                            listen: false)
                        .createCustomerBankAccountValidation(
                      validationData: _data,
                      notify: true,
                    );
                    break;
                  default:
                    _pleaseWaitNotifier.value = false;
                    break;
                }
              }
              _pleaseWaitNotifier.value = false;
            },
          );
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            'Add Bank Account',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );

  Widget get _buildPleaseWaitButton => Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Please Wait',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);

    /// Disposing Controller
    _accountNumber.dispose();
    _branchCode.dispose();
    _accountHolderName.dispose();

    /// Disposing ValueNotifier
    _pleaseWaitNotifier.dispose();
    super.dispose();
  }
}
