// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../app_providers/goCardLess/create_customer_bank_account_provider.dart';
import '../../app_providers/goCardLess/create_customer_provider.dart';
import '../../app_screens/goCardLess/goCardLess_add_customer_bank_account_screen.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/connect_goCardLess_payment_gateway.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';

class GoCardLessCreateCustomerScreen extends StatefulWidget {
  const GoCardLessCreateCustomerScreen({Key? key}) : super(key: key);

  @override
  _GoCardLessCreateCustomerScreenState createState() =>
      _GoCardLessCreateCustomerScreenState();
}

class _GoCardLessCreateCustomerScreenState
    extends State<GoCardLessCreateCustomerScreen> {
  int _initialFlag = 0;

  ///Controller
  final TextEditingController _email = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _addressLine1 = TextEditingController();
  final TextEditingController _addressLine2 = TextEditingController();
  final TextEditingController _addressLine3 = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _postCode = TextEditingController();

  ///Dropdown Id
  String? _countryId;
  String? _stateId;

  ///Dropdown List
  List _countryList = [];
  List _stateList = [];

  final ValueNotifier<int> _nameNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _pleaseWaitNotifier = ValueNotifier<bool>(false);

  Future<Response> _createCustomer(Map data) async {
    _pleaseWaitNotifier.value = true;
    String url = 'customers';
    var res = await ConnectGoCardLessPaymentGateway.postCallMethod(
      url,
      body: data,
    );
    debugPrint('$url Response:\t$res');
    return res;
  }

  Future _addCustomerInServer({required String customerId}) async {
    _pleaseWaitNotifier.value = true;
    var res = await AppApiCollection.addCustomer(
      email: ConnectHiveSessionData.getEmail,
      customerId: customerId,
    );
    return res;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();

    /// Initializing Dropdown
    Provider.of<CreateCustomerProvider>(context, listen: false)
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
          child: Consumer<CreateCustomerProvider>(
            builder: (context, service, _) {
              _countryList = service.country;
              _stateList = service.state;
              if (_countryList.isNotEmpty && _initialFlag == 0) {
                _countryId = _countryList[0]['alpha2Code'].toString();
                /*service.stateData(
                  region: _countryList[0]['region'].toString(),
                  notify: true,
                );*/
                _initialFlag++;
              }
              return HideKeyboard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar,
                    _buildBody(service: service),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar {
    return BuildAppBar(
      title: 'Set up Direct Debit',
    );
  }

  Widget _buildBody({
    required CreateCustomerProvider service,
  }) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        controller: ScrollController(),
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        children: <Widget>[
          BuildTextFormField(
            title: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: service.emailValidation,
          ),
          ValueListenableBuilder(
            valueListenable: _nameNotifier,
            builder: (context, notifierValue, _) {
              switch (notifierValue) {
                case 0:
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildTextFormField(
                        title: 'First Name',
                        controller: _firstName,
                        errorText: service.firstNameValidation,
                      ),
                      BuildTextFormField(
                        title: 'Last Name',
                        controller: _lastName,
                        errorText: service.lastNameValidation,
                      ),
                      if (padQuotes(service.baseValidation).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            padQuotes(service.baseValidation),
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: InkWell(
                          onTap: () {
                            _nameNotifier.value = 1;
                          },
                          child: Text(
                            'Click here to use a company name',
                            textAlign: TextAlign.start,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  );
                case 1:
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildTextFormField(
                        title: 'Company name',
                        controller: _companyName,
                        errorText: service.companyNameValidation,
                      ),
                      if (padQuotes(service.baseValidation).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            padQuotes(service.baseValidation),
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: InkWell(
                          onTap: () {
                            _nameNotifier.value = 0;
                          },
                          child: Text(
                            'Click here to use your name',
                            textAlign: TextAlign.start,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  );

                default:
                  return Container();
              }
            },
          ),
          BuildTextFormField(
            title: 'Address Line1',
            controller: _addressLine1,
            errorText: service.addressLine1Validation,
          ),
          BuildTextFormField(
            title: 'Address Line2',
            controller: _addressLine2,
            errorText: service.addressLine2Validation,
          ),
          BuildTextFormField(
            title: 'Address Line3',
            controller: _addressLine3,
            errorText: service.addressLine3Validation,
          ),
          BuildTextFormField(
            title: 'Town or City',
            controller: _city,
            errorText: service.cityValidation,
          ),
          BuildTextFormField(
            title: 'Post Code',
            controller: _postCode,
            errorText: service.postCodeValidation,
          ),
          BuildCountryDropdown(
            title: 'Country',
            initialValue: _countryId,
            listData: _countryList,
            onChange: (val) {
              _countryId = val.value;
              /*service.stateData(
                region: val.valueObject.meta,
                notify: true,
              );
              _stateId = "";*/
            },
            errorText: service.countryCodeValidation,
          ),
          /*buildStateDropdown(
            title: "State",
            initialValue: _stateId,
            listData: _stateList,
            onChange: (val) {
              _stateId = val.value;
            },
            errorText: service.stateValidation,
          ),*/
          SizedBox(height: 20),
          ValueListenableBuilder(
            valueListenable: _pleaseWaitNotifier,
            builder: (context, notifierValue, _) {
              if (notifierValue == true) {
                return _buildPleaseWaitButton;
              }
              return _buildCreateCustomerButton;
            },
          ),
        ],
      ),
    );
  }

  Widget get _buildCreateCustomerButton {
    return InkWell(
      onTap: () async {
        HideKeyboard.hide(context);
        Map data = {
          'customers': {
            'email': padQuotes(_email.text),
            if (_nameNotifier.value == 0)
              'given_name': padQuotes(_firstName.text),
            if (_nameNotifier.value == 0)
              'family_name': padQuotes(_lastName.text),
            if (_nameNotifier.value == 1)
              'company_name': padQuotes(_companyName.text),
            'address_line1': padQuotes(_addressLine1.text),
            'address_line2': padQuotes(_addressLine2.text),
            'address_line3': padQuotes(_addressLine3.text),
            'city': padQuotes(_city.text),
            'postal_code': padQuotes(_postCode.text),
            'country_code': padQuotes(_countryId),
          }
        };
        await _createCustomer(data).then(
          (dynamic res) async {
            if (res != null) {
              int _statusCode = res.statusCode;
              Map _data;
              switch (_statusCode) {
                case 201:
                  _data = json.decode(res.body);
                  Provider.of<CreateCustomerProvider>(context, listen: false)
                      .createCustomerValidationReset(
                    notify: true,
                  );
                  String customerId = padQuotes(_data['customers']['id']);
                  Map? addCustomerResponse =
                      await _addCustomerInServer(customerId: customerId);
                  if (addCustomerResponse != null &&
                      addCustomerResponse.containsKey('successMsg')) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider<
                            CreateCustomerBankAccountProvider>(
                          create: (context) =>
                              CreateCustomerBankAccountProvider(),
                          builder: (context, _) =>
                              GoCardLessAddCustomerBankAccountScreen(
                            customerId: customerId,
                          ),
                        ),
                      ),
                    );
                  }
                  break;
                case 422:
                  _data = json.decode(res.body);
                  Provider.of<CreateCustomerProvider>(context, listen: false)
                      .createCustomerValidation(
                    validationData: _data,
                    notify: true,
                  );
                  break;
                default:
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
          'Create Customer',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

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
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _companyName.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _addressLine3.dispose();
    _city.dispose();
    _postCode.dispose();

    /// Disposing ValueNotifier
    _nameNotifier.dispose();
    _pleaseWaitNotifier.dispose();
    super.dispose();
  }
}
