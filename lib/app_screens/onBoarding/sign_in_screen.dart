import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_providers/on_boarding_provider.dart';
import '../../app_screens/main_screen.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';
import '../pdf_view_screen.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';

enum SignInButtonStatus {
  disable,
  enable,
  loading,
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final ValueNotifier<SignInButtonStatus> _signInNotifier =
      ValueNotifier<SignInButtonStatus>(SignInButtonStatus.disable);
  final ValueNotifier<bool> _termsAndConditionSwitchNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> _privacySwitchNotifier = ValueNotifier<bool>(false);

  bool get isTcsAndPrivacyEnabled {
    return _termsAndConditionSwitchNotifier.value == true &&
        _privacySwitchNotifier.value == true;
  }

  void buttonStatus() {
    if (isTcsAndPrivacyEnabled == true) {
      _signInNotifier.value = SignInButtonStatus.enable;
    } else {
      _signInNotifier.value = SignInButtonStatus.disable;
    }
    return;
  }

  Future _signIn() async {
    _signInNotifier.value = SignInButtonStatus.loading;
    Map validateError = {};

    /// validation
    validateError.addAll({
      if (_email.text.isEmpty) 'email': 'Enter Email',
      if (_email.text.isNotEmpty && !isValidEmail(_email.text))
        'email': 'Enter Valid Email',
      if (_password.text.isEmpty) 'password': 'Enter Password',
    });

    if (validateError.isNotEmpty) {
      return {
        'validateError': validateError,
      };
    }

    var res = await AppApiCollection.login(
      email: _email.text,
      password: _password.text,
    );
    return res;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    setPreferredOrientations();
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
          child: Consumer<SignInProvider>(
            builder: (context, service, _) {
              return HideKeyboard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        controller: ScrollController(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        children: [
                          Text(
                            'Welcome',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          SizedBox(height: 50),
                          BuildLoginTextFormField(
                            controller: _email,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            errorText: padQuotes(service.email),
                          ),
                          BuildLoginTextFormField(
                            controller: _password,
                            hintText: 'Password',
                            obscureText: true,
                            errorText: padQuotes(service.password),
                          ),

                          /// Forgot Password
                          Container(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              onTap: () async {
                                HideKeyboard.hide(context);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider<
                                            ForgotPasswordProvider>(
                                      create: (context) =>
                                          ForgotPasswordProvider(),
                                      builder: (context, _) =>
                                          ForgotPasswordScreen(
                                        email: padQuotes(_email.text),
                                      ),
                                    ),
                                  ),
                                ).then((val) {
                                  Map<String, dynamic>? res = val;
                                  if (res != null &&
                                      res.containsKey('successMsg')) {
                                    showAppSnackBar(
                                      context: context,
                                      title: 'Forgot Password',
                                      response: res,
                                    );
                                  }
                                });
                              },
                              child: Opacity(
                                opacity: 0.6,
                                child: Text(
                                  'Forgot Password',
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          _buildSwitchContainer(
                              title: 'T&Cs',
                              switchNotifier: _termsAndConditionSwitchNotifier,
                              callback: () {
                                HideKeyboard.hide(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewScreen(
                                      pdfTitle: 'Terms and Condition',
                                      pdfLoadType: PdfLoadType.assets,
                                      assetPath:
                                          'assets/pdf/terms_and_conditions.pdf',
                                    ),
                                  ),
                                );
                              },
                              switchCallback: (val) {
                                HideKeyboard.hide(context);
                                _termsAndConditionSwitchNotifier.value = val;
                                if (_termsAndConditionSwitchNotifier.value &&
                                    _privacySwitchNotifier.value) {
                                  _signInNotifier.value =
                                      SignInButtonStatus.enable;
                                } else {
                                  _signInNotifier.value =
                                      SignInButtonStatus.disable;
                                }
                              }),
                          _buildSwitchContainer(
                            title: 'Privacy',
                            switchNotifier: _privacySwitchNotifier,
                            callback: () {
                              HideKeyboard.hide(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfViewScreen(
                                    pdfTitle: 'Privacy Policy',
                                    pdfLoadType: PdfLoadType.assets,
                                    assetPath: 'assets/pdf/Privacy_policy.pdf',
                                  ),
                                ),
                              );
                            },
                            switchCallback: (val) {
                              HideKeyboard.hide(context);
                              _privacySwitchNotifier.value = val;
                              if (_termsAndConditionSwitchNotifier.value &&
                                  _privacySwitchNotifier.value) {
                                _signInNotifier.value =
                                    SignInButtonStatus.enable;
                              } else {
                                _signInNotifier.value =
                                    SignInButtonStatus.disable;
                              }
                            },
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 4.5),
                          ValueListenableBuilder(
                            valueListenable: _signInNotifier,
                            builder:
                                (context, SignInButtonStatus notifierValue, _) {
                              switch (notifierValue) {
                                case SignInButtonStatus.disable:
                                  return _buildSignInButton(isEnable: false);
                                case SignInButtonStatus.enable:
                                  return _buildSignInButton();
                                case SignInButtonStatus.loading:
                                  return _buildPleaseWaitButton;
                                default:
                                  return _buildSignInButton();
                              }
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'No Account?',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                SizedBox(width: 5),
                                InkWell(
                                  splashColor: Theme.of(context).primaryColor,
                                  onTap: () async {
                                    HideKeyboard.hide(context);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeNotifierProvider<
                                                SignUpProvider>(
                                          create: (context) => SignUpProvider(),
                                          builder: (context, _) =>
                                              SignUpScreen(),
                                        ),
                                      ),
                                    ).then((value) {
                                      Map<String, dynamic>? res = value;
                                      if (res != null &&
                                          res.containsKey('successMsg')) {
                                        showAppSnackBar(
                                          context: context,
                                          title: 'Sign Up',
                                          response: res,
                                        );
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: const Color(0xe3000000),
                                          width: 1.8,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          _buildCopyRight,
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

  Widget get _buildCopyRight {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.copyright_outlined,
            size: 16.sp,
          ),
          SizedBox(width: 5),
          Text(
            'GreenPoint EV Ltd',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchContainer({
    required String title,
    required ValueNotifier<bool> switchNotifier,
    required VoidCallback callback,
    required ValueChanged<bool> switchCallback,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            splashColor: Theme.of(context).primaryColor,
            onTap: callback,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xe3000000),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Text(
                padQuotes(title),
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ),
          BuildSwitch(
            switchNotifier: switchNotifier,
            callback: switchCallback,
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton({isEnable = true}) {
    return InkWell(
      onTap: (isEnable)
          ? () async {
              HideKeyboard.hide(context);
              await _signIn().then((val) async {
                Map<String, dynamic>? res = val;
                buttonStatus();

                if (res != null && res.containsKey('validateError')) {
                  Provider.of<SignInProvider>(context, listen: false)
                      .signInValidation(
                          notify: true, validateError: res['validateError']);
                } else if (res != null && res.containsKey('errorMsg')) {
                  showAppSnackBar(
                    context: context,
                    title: 'Sign In',
                    response: res,
                  );
                } else if (res != null && res.containsKey('successMsg')) {
                  Provider.of<SignInProvider>(context, listen: false)
                      .signInValidation(notify: true, validateError: {});
                  await ConnectHiveSessionData.clearSessionData;
                  await ConnectHiveNetworkData.clearNetworkData;
                  ConnectHiveSessionData.setToken(res['token']);
                  ConnectHiveSessionData.setEmail(res['email']);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                } else {
                  showAppSnackBar(
                    context: context,
                    title: 'Sign In',
                    response: {
                      'warningMsg':
                          'something went wrong, please try after some time'
                    },
                  );
                }
              });
              buttonStatus();
            }
          : () {
              HideKeyboard.hide(context);
              List<String> message = <String>[];
              if (_termsAndConditionSwitchNotifier.value == false) {
                message.add('Terms & condition');
              }
              if (_privacySwitchNotifier.value == false) {
                message.add('Privacy Policy');
              }
              showAppSnackBar(
                context: context,
                title: 'SignIn',
                response: {'warningMsg': "Enable ${message.join(" and ")}"},
              );
            },
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: (isEnable)
              ? Color(0xffFB8C00)
              : Theme.of(context).unselectedWidgetColor,
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
          'Sign In',
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
      onTap: () async {
        HideKeyboard.hide(context);
      },
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Color(0xffFB8C00),
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
              SizedBox(width: 20.sp),
              SizedBox(
                height: 14.sp,
                width: 14.sp,
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
    _email.dispose();
    _password.dispose();
    _termsAndConditionSwitchNotifier.dispose();
    _privacySwitchNotifier.dispose();
    _signInNotifier.dispose();
    super.dispose();
  }
}
