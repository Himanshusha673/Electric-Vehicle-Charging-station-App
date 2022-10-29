import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';

import '../../app_common_widgets/shimmers/shimmers.dart';
import '../../app_providers/home/home_screen_list_view_provider.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_services/user_location_service.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/widgets/widgets.dart';
import 'start_charging_screen.dart';

class HomeScreenListView extends StatefulWidget {
  final GlobalKey<ScaffoldState>? mainScaffoldKey;

  const HomeScreenListView({
    Key? key,
    this.mainScaffoldKey,
  }) : super(key: key);

  @override
  _HomeScreenListViewState createState() => _HomeScreenListViewState();
}

class _HomeScreenListViewState extends State<HomeScreenListView> {
  final StreamController _streamDataController = StreamController();
  final StreamController _streamSearchController = StreamController();
  final TextEditingController _textEditingController = TextEditingController();
  final DeBouncer _deBouncer = DeBouncer();
  final UserLocationService _userLocationService = UserLocationService.instance;
  List _chargeBoxList = [];
  bool _isLoading = false;

  Future _getChargePointLocation() async {
    _isLoading = true;
    var res = await AppApiCollection.getHomeData();
    if (res != null && numeric(res['totalCount']) > 0) {
      Map data = {};
      List details = [];
      data = res as Map;
      details = data['details'] as List;

      _chargeBoxList = details;

      if (_chargeBoxList.isNotEmpty) {
        Location location = Location();
        bool isLocationServiceEnabled;
        LocationPermission checkPermission;
        isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

        switch (isLocationServiceEnabled) {

          /// Location Service enabled
          case true:
            checkPermission = await Geolocator.checkPermission();

            /// LocationPermission.denied or LocationPermission.deniedForever
            if (checkPermission == LocationPermission.deniedForever ||
                checkPermission == LocationPermission.denied) {
              var res = await showLocationPermissionDialog(
                context: context,
                locationPermission: checkPermission,
              );
              switch (res) {
                case 'continue':
                  checkPermission = await Geolocator.requestPermission();
                  break;
                case 'settings':
                  await Geolocator.openAppSettings();
                  break;
              }
            }

            /// LocationPermission.whileInUse or LocationPermission.always
            else if (checkPermission == LocationPermission.whileInUse ||
                checkPermission == LocationPermission.always) {
              break;
            } else {}
            break;

          /// Location Service not enabled
          case false:
            var res = await showLocationEnableDialog(context: context);
            if (res == 'continue') {
              isLocationServiceEnabled = await location.requestService();
            }
            if (isLocationServiceEnabled == true) {
              checkPermission = await Geolocator.checkPermission();

              /// LocationPermission.denied or LocationPermission.deniedForever
              if (checkPermission == LocationPermission.deniedForever ||
                  checkPermission == LocationPermission.denied) {
                var res = await showLocationPermissionDialog(
                  context: context,
                  locationPermission: checkPermission,
                );
                switch (res) {
                  case 'continue':
                    checkPermission = await Geolocator.requestPermission();
                    break;
                  case 'settings':
                    await Geolocator.openAppSettings();
                    break;
                }
              }

              /// LocationPermission.whileInUse or LocationPermission.always
              else if (checkPermission == LocationPermission.whileInUse ||
                  checkPermission == LocationPermission.always) {
                break;
              } else {}
            } else {}

            break;
          default:
            break;
        }

        isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
        checkPermission = await Geolocator.checkPermission();
        if (isLocationServiceEnabled == true &&
            (checkPermission == LocationPermission.whileInUse ||
                checkPermission == LocationPermission.always)) {
          await _performAction();
        }
      }
    }
    if (!_streamDataController.isClosed) {
      Provider.of<HomeScreenListViewProvider>(context, listen: false).setData(
        chargeBoxList: _chargeBoxList,
      );
      _streamDataController.sink.add(_chargeBoxList);
    }
    _isLoading = false;
  }

  Future _performAction() async {
    // debugPrint("performAction");
    await _userLocationService.initialize();

    /// removing unknown location from list
    // debugPrint("removing unknown location from list");
    _chargeBoxList.retainWhere((data) {
      return double.tryParse(padQuotes(data['latitude'])) != null &&
          double.tryParse(padQuotes(data['longitude'])) != null;
    });

    /// inserting distance
    // debugPrint("inserting distance");
    _chargeBoxList.map((element) {
      Map<String, dynamic> data = element;
      (element as Map<String, dynamic>).addAll({
        'distance': Geolocator.distanceBetween(
          _userLocationService.getPosition!.latitude,
          _userLocationService.getPosition!.longitude,
          double.parse(data['latitude'].toString()),
          double.parse(data['longitude'].toString()),
        ),
      });
    }).toList();

    /// sort location according to distance
    // debugPrint("sort location according to distance");
    _chargeBoxList.sort(
      (a, b) {
        return double.parse(a['distance'].toString())
            .compareTo(double.parse(b['distance'].toString()));
      },
    );
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _getChargePointLocation();
    _textEditingController.addListener(() {
      _streamSearchController.sink.add(_textEditingController.text);
    });
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
          child: HideKeyboard(
            child: Consumer<HomeScreenListViewProvider>(
              builder: (context, notifierProvider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchField(notifierProvider),
                    Expanded(
                      child: StreamBuilder(
                        stream: _streamDataController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildShimmerLoader;
                          } else if (snapshot.hasData) {
                            if (notifierProvider
                                .getFilteredChargeBoxList.isNotEmpty) {
                              return RefreshIndicator(
                                color: Theme.of(context).primaryColor,
                                onRefresh: () async => Future.wait([
                                  _getChargePointLocation(),
                                ]),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  controller: ScrollController(),
                                  padding: EdgeInsets.zero,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: notifierProvider
                                      .getFilteredChargeBoxList.length,
                                  itemBuilder: (context, index) {
                                    Map detailsData = notifierProvider
                                        .getFilteredChargeBoxList[index];
                                    return _buildChargeBoxData(detailsData);
                                  },
                                  separatorBuilder: (context, index) =>
                                      Divider(height: 0.0),
                                ),
                              );
                            } else if (notifierProvider
                                .getChargeBoxList.isEmpty) {
                              return _buildNoChargingPoints;
                            } else if (notifierProvider
                                .getFilteredChargeBoxList.isEmpty) {
                              return _buildNothingFound;
                            }
                            return Container();
                          } else if (snapshot.data == null) {
                            return _buildTryLater;
                          } else if (snapshot.hasError) {
                            return _buildTryLater;
                          } else {
                            return _buildShimmerLoader;
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget get _buildTryLater {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              if (_isLoading == false) {
                _getChargePointLocation();
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor,
              shape: CircleBorder(),
              padding: EdgeInsets.all(12.0),
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: Theme.of(context).primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'something went wrong, Please try after some time',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget get _buildNoChargingPoints {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      alignment: Alignment.center,
      child: Text('No charging points near by'),
    );
  }

  Widget get _buildNothingFound {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      alignment: Alignment.center,
      child: Text('Nothing found'),
    );
  }

  Widget get _buildCircularLoader {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget get _buildShimmerLoader {
    return BuildShimmer(
      child: ListView.separated(
        itemCount: 20,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BuildShimmerContainer(
                      width: MediaQuery.of(context).size.width / 3),
                  Container(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              BuildShimmerContainer(
                  width: MediaQuery.of(context).size.width / 1.5),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location_outlined,
                        size: 18.sp,
                      ),
                      SizedBox(width: 5),
                      BuildShimmerContainer(width: 100),
                    ],
                  ),
                  Flexible(
                    child: BuildShimmerContainer(width: 100),
                  ),
                ],
              ),
            ],
          ),
        ),
        separatorBuilder: (context, index) => Divider(height: 0.0),
      ),
    );
  }

  Widget _buildChargeBoxData(Map detailsData) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      onTap: () {
        HideKeyboard.hide(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StartChargingScreen(
                chargeBoxId: detailsData['charge_box_id'],
                chargeType: detailsData['charge_type'], 
                tariffData: detailsData['tariff'],
              ),
            ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  padQuotes(detailsData['city']),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Container(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              padQuotes(detailsData['street']),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.my_location_outlined,
                      size: 18.sp,
                    ),
                    SizedBox(width: 5),
                    Text(
                      padQuotes(detailsData['distance']).isNotEmpty
                          ? padQuotes(
                              convertToDistance(detailsData['distance']))
                          : 'unknown',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    padQuotes(detailsData['connector_description']),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(HomeScreenListViewProvider notifierProvider) {
    return StreamBuilder(
      stream: _streamSearchController.stream,
      builder: (context, snapshot) {
        String? _searchQuery;
        if (snapshot.hasData && snapshot.data != null) {
          _searchQuery = snapshot.data as String?;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: TextFormField(
            controller: _textEditingController,
            onTap: () {
              /*showSearch(
              context: context,
              delegate: HomeScreenListViewSearch(
                myLatitude: this._myLatitude,
                myLongitude: this._myLongitude,
              ),
            );*/
            },
            onChanged: (val) {
              _deBouncer.run(() {
                notifierProvider.applyFilter(val);
              }, delay: Duration(milliseconds: 0));
            },
            onFieldSubmitted: (val) {
              notifierProvider.applyFilter(val);
            },
            style: Theme.of(context).textTheme.bodyText1,
            decoration: InputDecoration(
              hintText: 'Search by post code',
              /*hintStyle: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.w400,
                  ),*/
              focusColor: Theme.of(context).primaryColor,
              isDense: true,
              prefixIcon: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search_rounded,
                  size: 20.sp,
                ),
              ),
              suffixIcon: (padQuotes(_searchQuery).isNotEmpty)
                  ? IconButton(
                      onPressed: () {
                        _textEditingController.text = '';
                        notifierProvider
                            .applyFilter(_textEditingController.text);
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 20.sp,
                      ),
                    )
                  : null /*IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.mic_outlined,
                        size: 20.sp,
                      ),
                    )*/
              ,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    _streamDataController.close();
    _streamSearchController.close();
    _textEditingController.dispose();
    super.dispose();
  }
}