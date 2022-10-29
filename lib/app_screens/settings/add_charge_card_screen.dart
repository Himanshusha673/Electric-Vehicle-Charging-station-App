import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';

enum ConfirmButtonStatus {
  disable,
  enable,
  loading,
}

class AddChargeCardScreen extends StatefulWidget {
  const AddChargeCardScreen({Key? key}) : super(key: key);

  @override
  _AddChargeCardScreenState createState() => _AddChargeCardScreenState();
}

class _AddChargeCardScreenState extends State<AddChargeCardScreen> {
  late TextEditingController _appIdController;
  late ValueNotifier<bool> _pleaseWaitNotifier;

  Future _addChargeCard() async {
    var res = await AppApiCollection.getIdTag(appId: _appIdController.text);
    return res;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _appIdController = TextEditingController();
    _pleaseWaitNotifier = ValueNotifier<bool>(false);
    _appIdController.text = padQuotes(ConnectHiveSessionData.getAppId);
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
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HideKeyboard.hide(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar,
                    _buildBody,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar {
    return BuildAppBar(title: 'Add Charge Card');
  }

  Widget get _buildBody {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        controller: ScrollController(),
        padding: EdgeInsets.symmetric(vertical: 20.0),
        children: <Widget>[
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              'Enter your token id',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Divider(),
          SizedBox(
            height: 150.sp, //200
            child: Image.asset(
              'assets/images/Fobtokenid.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 20),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: TextFormField(
              controller: _appIdController,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 30,
                  ),
              maxLength: 14,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                prefixIcon: SizedBox(
                  height: 10.sp,
                  child: Image.asset(
                    'assets/images/Fobfront.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                counterText: '',
                hintText: 'GP-XXXX*XXXX',
                hintStyle: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Colors.grey,
                      fontSize: 25.sp,
                    ),
              ),
            ),
          ),
          Divider(),
          SizedBox(height: MediaQuery.of(context).size.height / 6.2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ValueListenableBuilder(
              valueListenable: _pleaseWaitNotifier,
              builder: (context, bool notifierValue, _) {
                if (notifierValue) {
                  return _buildPleaseWaitButton;
                }
                return _buildConfirmButton;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget get _buildConfirmButton {
    return InkWell(
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        _pleaseWaitNotifier.value = true;
        await _addChargeCard().then((val) {
          _pleaseWaitNotifier.value = false;
          Map<String, dynamic>? res = val;
          if (res != null && res.containsKey('successMsg')) {
            Map details = res['details'];
            ConnectHiveSessionData.setAppId(padQuotes(_appIdController.text));
            ConnectHiveSessionData.setIdTag(padQuotes(details['id_tag']));
            Navigator.of(context).pop(res);
          } else if (res != null && res.containsKey('errorMsg')) {
            showAppSnackBar(
              context: context,
              title: 'Add Charge Card',
              response: res,
            );
          }
        });
      },
      borderRadius: BorderRadius.circular(30.0),
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
        child: Text(
          'Confirm',
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
              SizedBox(width: 20),
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
    _appIdController.dispose();
    _pleaseWaitNotifier.dispose();
    super.dispose();
  }
}
