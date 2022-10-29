import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:provider/provider.dart';

import '../../app_providers/on_boarding_provider.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/app_theme.dart';
import '../../app_utils/widgets/widgets.dart';

enum _PageType {
  sendOtp,
  verifyOtp,
  resetPassword,
}

class ForgotPasswordScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordScreen({
    Key? key,
    this.email,
  }) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _verificationCode = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final ValueNotifier<_PageType> _pageNotifier =
      ValueNotifier<_PageType>(_PageType.sendOtp);
  final ValueNotifier<bool> _pleaseWaitNotifier = ValueNotifier<bool>(false);
  String? randomNumber;

  /// Send Mail
  _sendMail({
    required String userName,
  }) async {
    debugPrint('sendMail');
    randomNumber = generateRandomNumber().toString();

    // final smtpServer = gmail(username, password);

    final smtpServer = SmtpServer(
      'mail.fitmodus.de',
      port: 465,
      name: 'occp',
      ignoreBadCertificate: false,
      allowInsecure: true,
      ssl: true,
      username: '_mainaccount@fitmodus.de',
      password: 'inindiatech@inindiatech',
      xoauth2Token: '',
    );

    final message = Message()
      ..from = Address('noreplay@fitmodus.de', '')
      ..recipients.add(padQuotes(_email.text))
      ..subject = 'Reset Password'
      ..text = ''
      ..html = '<h1>Hi,</h1>'
              '<br/>'
              '<p>Please enter the verification code <strong>' +
          randomNumber! +
          '</strong> on the forgot password screen to change password.</p>';

    try {
      final sendReport = await send(message, smtpServer);
      await _storeOtp();
      debugPrint('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      debugPrint('Message not sent.');
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  /// Check Valid Email
  Future _checkValidEmail() async {
    _pleaseWaitNotifier.value = true;
    Map validateError = {};

    /// validation
    validateError.addAll({
      if (_email.text.isEmpty) 'email': 'Enter Email',
      if (_email.text.isNotEmpty && !isValidEmail(_email.text))
        'email': 'Enter Valid Email',
    });

    if (validateError.isNotEmpty) {
      return {
        'validateError': validateError,
      };
    }

    var res = await AppApiCollection.checkValidEmail(email: _email.text);
    return res;
  }

  /// Store Otp
  Future _storeOtp() async {
    var res =
        await AppApiCollection.storeOtp(email: _email.text, otp: randomNumber);
    return res;
  }

  /// Verify Otp
  Future _verifyOtp() async {
    _pleaseWaitNotifier.value = true;
    Map validateError = {};

    /// validation
    validateError.addAll({
      if (_verificationCode.text.isEmpty)
        'verificationCode': 'Enter 6 digit verification code',
    });
    if (validateError.isNotEmpty) {
      return {
        'validateError': validateError,
      };
    }
    var res = await AppApiCollection.verifyOtp(
      email: _email.text,
      otp: _verificationCode.text,
    );
    return res;
  }

  /// Reset Password
  Future _resetPassword() async {
    _pleaseWaitNotifier.value = true;
    Map validateError = {};

    /// validation
    validateError.addAll({
      if (_password.text.isEmpty) 'password': 'Enter Password',
      if (_confirmPassword.text.isEmpty)
        'confirmPassword': 'Enter Confirm Password',
      if (_confirmPassword.text.isNotEmpty &&
          _password.text.isNotEmpty &&
          _confirmPassword.text.compareTo(_password.text) != 0)
        'confirmPassword': 'Password is Not Matching',
    });
    if (validateError.isNotEmpty) {
      return {
        'validateError': validateError,
      };
    }
    var res = await AppApiCollection.resetPassword(
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
          child: Consumer<ForgotPasswordProvider>(
            builder: (context, ForgotPasswordProvider service, _) {
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
                            horizontal: 10.0, vertical: 10.0),
                        children: [
                          SizedBox(height: 40),
                          ValueListenableBuilder(
                            valueListenable: _pageNotifier,
                            builder: (context, notifierValue, _) {
                              switch (notifierValue) {

                                /// Send Otp
                                case _PageType.sendOtp:
                                  return _buildSendOtpBody(service: service);

                                /// verify Otp
                                case _PageType.verifyOtp:
                                  return _buildVerifyOtpBody(service: service);

                                /// reset Password
                                case _PageType.resetPassword:
                                  return _buildResetPasswordBody(
                                      service: service);

                                /// Send Otp
                                default:
                                  return _buildSendOtpBody(service: service);
                              }
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

  /// Build AppBar
  Widget get _buildAppBar {
    return BuildAppBar(title: 'Forgot Password');
  }

  /// Build Send Otp Body
  Widget _buildSendOtpBody({required ForgotPasswordProvider service}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send code via email',
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 10),
        BuildSignUpTextFormField(
          labelText: 'Email',
          hintText: 'Enter Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          errorText: padQuotes(service.email),
        ),
        SizedBox(height: 40),
        ValueListenableBuilder(
          valueListenable: _pleaseWaitNotifier,
          builder: (context, notifierValue, _) {
            if (notifierValue == true) {
              return _buildPleaseWaitButton;
            }
            return _buildNextButton(
              callback: () async {
                HideKeyboard.hide(context);
                await _checkValidEmail().then((val) async {
                  Map<String, dynamic>? res = val;
                  if (res != null && res.containsKey('successMsg')) {
                    service.forgotPasswordValidation(
                        notify: true, validateError: {});
                    _pleaseWaitNotifier.value = false;
                    _sendMail(userName: padQuotes(res['name']));
                    _pageNotifier.value = _PageType.verifyOtp;
                  } else if (res != null && res.containsKey('errorMsg')) {
                    _pleaseWaitNotifier.value = false;
                    Provider.of<ForgotPasswordProvider>(context, listen: false)
                        .setEmail(padQuotes(res['errorMsg']));
                  } else if (res != null && res.containsKey('validateError')) {
                    _pleaseWaitNotifier.value = false;
                    service.forgotPasswordValidation(
                        notify: true, validateError: res['validateError']);
                  }
                });
                _pleaseWaitNotifier.value = false;
              },
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  /// Build Verify Otp Body
  Widget _buildVerifyOtpBody({required ForgotPasswordProvider service}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We Sent Your code to:\n' + padQuotes(_email.text),
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 10),
        Text(
          'Please check your email for a message with your code.'
          ' Your code is 6 numbers long.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        InkWell(
          onTap: () {
            _pageNotifier.value = _PageType.sendOtp;
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              "Didn't get a code?",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: AppTheme.checkMarkBlue,
                  ),
            ),
          ),
        ),
        SizedBox(height: 10),
        BuildSignUpTextFormField(
          labelText: 'Verification Code',
          hintText: 'Enter the 6-digit code',
          maxLength: 6,
          controller: _verificationCode,
          keyboardType: TextInputType.number,
          errorText: padQuotes(service.verificationCode),
        ),
        SizedBox(height: 40),
        ValueListenableBuilder(
          valueListenable: _pleaseWaitNotifier,
          builder: (context, notifierValue, _) {
            if (notifierValue == true) {
              return _buildPleaseWaitButton;
            }
            return _buildNextButton(
              callback: () async {
                HideKeyboard.hide(context);
                await _verifyOtp().then((res) {
                  if (res != null && (res as Map).containsKey('successMsg')) {
                    service.forgotPasswordValidation(
                        notify: true, validateError: {});
                    _pleaseWaitNotifier.value = false;
                    _pageNotifier.value = _PageType.resetPassword;
                  } else if (res != null &&
                      (res as Map).containsKey('errorMsg')) {
                    _pleaseWaitNotifier.value = false;
                    service.setVerificationCode(padQuotes(res['errorMsg']));
                  } else if (res != null && res.containsKey('validateError')) {
                    _pleaseWaitNotifier.value = false;
                    service.forgotPasswordValidation(
                        notify: true, validateError: res['validateError']);
                  }
                });
                _pleaseWaitNotifier.value = false;
              },
            );
          },
        ),
        SizedBox(height: 20),
        _buildCancelButton(
          callback: () {
            HideKeyboard.hide(context);
            _pageNotifier.value = _PageType.sendOtp;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  /// Build Reset Password Body
  Widget _buildResetPasswordBody({required ForgotPasswordProvider service}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a New Password',
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 10),
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
              Provider.of<ForgotPasswordProvider>(context, listen: false)
                  .setConfirmPassword('Enter Confirm Password');
            }
            if (val.isNotEmpty &&
                _password.text.isNotEmpty &&
                val.compareTo(_password.text) != 0) {
              Provider.of<ForgotPasswordProvider>(context, listen: false)
                  .setConfirmPassword('Password is Not Matching');
            }
            if (val.isNotEmpty &&
                _password.text.isNotEmpty &&
                val.compareTo(_password.text) == 0) {
              Provider.of<ForgotPasswordProvider>(context, listen: false)
                  .setConfirmPassword('');
            }
          },
          errorText: padQuotes(service.confirmPassword),
        ),
        SizedBox(height: 40),
        ValueListenableBuilder(
          valueListenable: _pleaseWaitNotifier,
          builder: (context, notifierValue, _) {
            if (notifierValue == true) {
              return _buildPleaseWaitButton;
            }
            return _buildChangePasswordButton(
              callback: () async {
                HideKeyboard.hide(context);
                await _resetPassword().then((val) {
                  Map<String, dynamic>? res = val;
                  if (res != null && res.containsKey('successMsg')) {
                    _pleaseWaitNotifier.value = false;
                    service.forgotPasswordValidation(
                        notify: true, validateError: {});
                    Navigator.pop(context, res);
                  } else if (res != null && res.containsKey('validateError')) {
                    _pleaseWaitNotifier.value = false;
                    service.forgotPasswordValidation(
                        notify: true, validateError: res['validateError']);
                  }
                });
                _pleaseWaitNotifier.value = false;
              },
            );
          },
        ),
        SizedBox(height: 20),
        _buildCancelButton(
          callback: () {
            HideKeyboard.hide(context);
            _pageNotifier.value = _PageType.verifyOtp;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  /// Build Next Button
  Widget _buildNextButton({
    GestureTapCallback? callback,
  }) {
    return InkWell(
      onTap: callback,
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Theme.of(context).primaryColor,
        ),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Next',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }

  /// Build Cancel Button
  Widget _buildCancelButton({
    GestureTapCallback? callback,
  }) {
    return InkWell(
      onTap: callback,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Cancel',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
      ),
    );
  }

  /// Build Change Password Button
  Widget _buildChangePasswordButton({
    GestureTapCallback? callback,
  }) {
    return InkWell(
      onTap: callback,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Theme.of(context).primaryColor,
        ),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Change Password',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }

  /// Build PleaseWait Button
  Widget get _buildPleaseWaitButton {
    return Container(
      margin: EdgeInsets.all(2.0),
      padding: EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Theme.of(context).primaryColor,
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
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);

    ///Disposing Controller
    _email.dispose();
    _verificationCode.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _pageNotifier.dispose();
    _pleaseWaitNotifier.dispose();
    super.dispose();
  }
}
