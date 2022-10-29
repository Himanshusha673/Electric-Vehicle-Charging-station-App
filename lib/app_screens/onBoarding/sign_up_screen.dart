import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_providers/on_boarding_provider.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final ValueNotifier<bool> _pleaseWaitNotifier = ValueNotifier<bool>(false);

  Future _signUp() async {
    _pleaseWaitNotifier.value = true;
    Map validateError = {};

    /// validation
    validateError.addAll({
      if (_firstName.text.isEmpty) 'firstName': 'Enter First Name',
      if (_lastName.text.isEmpty) 'lastName': 'Enter Last Name',
      if (_email.text.isEmpty) 'email': 'Enter Email',
      if (_email.text.isNotEmpty && !isValidEmail(_email.text))
        'email': 'Enter Valid Email',
      if (_password.text.isEmpty) 'password': 'Enter Password',
      if (_confirmPassword.text.isEmpty)
        'confirmPassword': 'Enter Confirm Password',
      if (_confirmPassword.text.isNotEmpty &&
          _password.text.isNotEmpty &&
          _confirmPassword.text.compareTo(_password.text) != 0)
        'confirmPassword': 'Password is Not Matching',
    });

    if (validateError.isNotEmpty) {
      return {'validateError': validateError};
    }
    var res = await AppApiCollection.register(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
      password: _password.text,
    );
    return res;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
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
          child: Consumer<SignUpProvider>(
            builder: (context, service, _) {
              return HideKeyboard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar,
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        controller: ScrollController(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20.0),
                        children: [
                          BuildSignUpTextFormField(
                            labelText: 'First Name',
                            hintText: 'Enter First Name',
                            controller: _firstName,
                            errorText: padQuotes(service.firstName),
                          ),
                          BuildSignUpTextFormField(
                            labelText: 'Last Name',
                            hintText: 'Enter Last Name',
                            controller: _lastName,
                            errorText: padQuotes(service.lastName),
                          ),
                          BuildSignUpTextFormField(
                            labelText: 'Email',
                            hintText: 'Enter Email',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            errorText: padQuotes(service.email),
                          ),
                          BuildSignUpTextFormField(
                            labelText: 'Password',
                            hintText: 'Enter Password',
                            controller: _password,
                            obscureText: true,
                            errorText: padQuotes(service.password),
                          ),
                          BuildSignUpTextFormField(
                            labelText: 'Confirm Password',
                            hintText: 'Enter Confirm Password',
                            controller: _confirmPassword,
                            obscureText: true,
                            onChanged: (val) {
                              if (val.isEmpty) {
                                Provider.of<SignUpProvider>(context,
                                        listen: false)
                                    .setConfirmPassword(
                                        'Enter Confirm Password');
                              }
                              if (val.isNotEmpty &&
                                  _password.text.isNotEmpty &&
                                  val.compareTo(_password.text) != 0) {
                                Provider.of<SignUpProvider>(context,
                                        listen: false)
                                    .setConfirmPassword(
                                        'Password is Not Matching');
                              }
                              if (val.isNotEmpty &&
                                  _password.text.isNotEmpty &&
                                  val.compareTo(_password.text) == 0) {
                                Provider.of<SignUpProvider>(context,
                                        listen: false)
                                    .setConfirmPassword('');
                              }
                            },
                            errorText: padQuotes(service.confirmPassword),
                          ),
                          SizedBox(height: 30),
                          ValueListenableBuilder(
                            valueListenable: _pleaseWaitNotifier,
                            builder: (context, value, _) {
                              if (value == true) {
                                return _buildPleaseWaitButton;
                              }
                              return _buildSignUpButton;
                            },
                          ),
                        ],
                      ),
                    ),
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
    return BuildAppBar(title: 'Sign Up');
  }

  Widget get _buildSignUpButton {
    return InkWell(
      onTap: () async {
        HideKeyboard.hide(context);
        await _signUp().then((val) {
          Map<String, dynamic>? res = val;
          if (res != null && res.containsKey('validateError')) {
            _pleaseWaitNotifier.value = false;
            Provider.of<SignUpProvider>(context, listen: false)
                .signUpValidation(
                    notify: true, validateError: res['validateError']);
          } else if (res != null && res.containsKey('errorMsg')) {
            _pleaseWaitNotifier.value = false;
            showAppSnackBar(
              context: context,
              title: 'Sign Up',
              response: res,
            );
          } else if (res != null && res.containsKey('successMsg')) {
            _pleaseWaitNotifier.value = false;
            Navigator.pop(context, res);
          } else {
            _pleaseWaitNotifier.value = false;
            showAppSnackBar(
              context: context,
              title: 'Sign Up',
              response: {
                'warningMsg': 'something went wrong, please try after some time'
              },
            );
          }
        });
        _pleaseWaitNotifier.value = false;
      },
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(30.0),
          /*boxShadow: [
              BoxShadow(
                color: const Color(0x4d6924c6),
                offset: Offset(16.911571502685547, -2.0710700949361227e-15),
                blurRadius: 33.823143005371094,
              ),
            ],*/
        ),
        width: double.infinity,
        child: Text(
          'Sign Up',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

  Widget get _buildPleaseWaitButton {
    return InkWell(
      onTap: () async {},
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(30.0),
          /*boxShadow: [
              BoxShadow(
                color: const Color(0x4d6924c6),
                offset: Offset(16.911571502685547, -2.0710700949361227e-15),
                blurRadius: 33.823143005371094,
              ),
            ],*/
        ),
        width: double.infinity,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please Wait',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              SizedBox(width: 20),
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);

    ///Disposing Controller
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _pleaseWaitNotifier.dispose();
    super.dispose();
  }
}
