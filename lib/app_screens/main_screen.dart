import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../app_providers/home/home_screen_list_view_provider.dart';
import '../app_providers/home/home_screen_map_view_provider.dart';
import '../app_providers/settings_provider.dart';
import '../app_screens/settings/settings_screen.dart';
import '../app_utils/app_functions.dart';
import '../app_utils/connect/hive/connect_hive.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'home/home_screen_list_view.dart';
import 'home/home_screen_map_view.dart';
import 'home/stop_charging_screen.dart';

class MainScreen extends StatefulWidget {
  final HomeBottomNavigationItem? homeBottomNavigationItem;

  const MainScreen({Key? key, this.homeBottomNavigationItem}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ValueNotifier<int> _pageIndexNotifier = ValueNotifier<int>(0);

  final List<bool> _isHomeViewType = [false, true];
  final ValueNotifier<HomeViewType> _homeViewTypeNotifier =
      ValueNotifier<HomeViewType>(HomeViewType.list);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var mapResponse = {};
  var sapResponse;
  bool status = false;

  Stream<bool?> stat() async* {
    http.Response responseL;
    String url =
        'https://api.greenpointev.com/inindia.tech/public/api/CharingStatus/${ConnectHiveSessionData.getEmail}';
    responseL = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    print("${responseL.body}");
    sapResponse = jsonDecode(responseL.body);
    yield !sapResponse['status'];
  }

  Future apicall() async {
    http.Response responseL;
    //responseL=status as http.Response;
    String url =
        'https://api.greenpointev.com/inindia.tech/public/api/CharingStatus/${ConnectHiveSessionData.getEmail}';
    responseL = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    print("${responseL.statusCode}");
    print("${responseL.body}");

    if (responseL.statusCode == 200) {
      setState(() {
        mapResponse = json.decode(responseL.body);
        print("data");
      });
    }
  }

  void _initialize() {
    setPreferredOrientations();
    _pageIndexNotifier.value = (widget.homeBottomNavigationItem != null)
        ? getIndexByHomeBottomNavigationItem(widget.homeBottomNavigationItem)
        : 0;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _initialize();
    apicall();
    stat();
  }

  @override
  Widget build(BuildContext context) {
    // apicall();
    stat();
    return Scaffold(
      key: _scaffoldKey,
      body: _buildBody,
      floatingActionButton: _buildFabButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar,
    );
  }

  Widget get _buildBody {
    return ValueListenableBuilder(
      valueListenable: _pageIndexNotifier,
      builder: (context, index, _) {
        switch (index) {
          /// Home Screen
          case 0:
            return ValueListenableBuilder<HomeViewType>(
              valueListenable: _homeViewTypeNotifier,
              builder: (context, notifierValue, _) {
                /*return IndexedStack(
                  index: notifierValue.index,
                  children: [
                    ChangeNotifierProvider<HomeScreenListViewProvider>(
                      create: (context) => HomeScreenListViewProvider(),
                      builder: (context, child) => child,
                      child: HomeScreenListView(mainScaffoldKey: _scaffoldKey),
                    ),
                    ChangeNotifierProvider<HomeScreenMapViewProvider>(
                      create: (context) => HomeScreenMapViewProvider(),
                      builder: (context, _) =>
                          HomeScreenMapView(mainScaffoldKey: _scaffoldKey),
                    )
                  ],
                );*/
                switch (notifierValue) {
                  case HomeViewType.list:
                    return ChangeNotifierProvider<HomeScreenListViewProvider>(
                      create: (context) => HomeScreenListViewProvider(),
                      builder: (context, child) => child!,
                      child: HomeScreenListView(mainScaffoldKey: _scaffoldKey),
                    );
                  case HomeViewType.map:
                    return ChangeNotifierProvider<HomeScreenMapViewProvider>(
                      create: (context) => HomeScreenMapViewProvider(),
                      builder: (context, _) =>
                          HomeScreenMapView(mainScaffoldKey: _scaffoldKey),
                    );
                  default:
                    return Container();
                }
              },
            );

          /// History Screen
          case 1:
            return HistoryScreen(mainScaffoldKey: _scaffoldKey);
          // Charging Icon
          case 2:
            return StopChargingScreen(mainScaffoldKey: _scaffoldKey);

          /// Dashboard Screen
          case 3:
            return DashBoardScreen(mainScaffoldKey: _scaffoldKey);

          /// Settings Screen
          case 4:
            return ChangeNotifierProvider(
              create: (context) => SettingsProvider(),
              builder: (context, _) =>
                  SettingsScreen(mainScaffoldKey: _scaffoldKey),
            );
          default:
            return Container();
        }
      },
    );
  }

  Widget get _buildBottomNavigationBar {
    return ValueListenableBuilder(
      valueListenable: _pageIndexNotifier,
      builder: (context, index, _) {
        return Container(
          decoration: BoxDecoration(
              border: Border(
            top: BorderSide(
              color: Color(0xff29434E),
              width: 1,
            ),
          )),
          child: BottomNavigationBar(
            elevation: 8.0,
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            type: BottomNavigationBarType.fixed,
            currentIndex: _pageIndexNotifier.value,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            iconSize: 30.sp,
            selectedLabelStyle: TextStyle(
              fontSize: 10.0.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 10.0.sp,
            ),
            onTap: (index) {
              if (index != 5) {
                _pageIndexNotifier.value = index;
              }
            },
            items: [
              /// Home
              BottomNavigationBarItem(
                activeIcon: _buildActiveIcon('assets/svg/Home.svg'),
                icon: SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: SvgPicture.asset(
                    'assets/svg/Home.svg',
                  ),
                ),
                label: 'Home',
              ),

              ///History
              BottomNavigationBarItem(
                activeIcon: _buildActiveIcon('assets/svg/History.svg'),
                icon: SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: SvgPicture.asset(
                    'assets/svg/History.svg',
                  ),
                ),
                label: 'History',
              ),

              /// Charging Status
              BottomNavigationBarItem(
                icon: Tooltip(
                    message: 'Charging Status Alert!',
                    child: _buildChargingStatusButton),
                label: '',
              ),

              /// Dashboard
              BottomNavigationBarItem(
                activeIcon: _buildActiveIcon('assets/svg/Dashboard.svg'),
                icon: SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: SvgPicture.asset(
                    'assets/svg/Dashboard.svg',
                  ),
                ),
                label: 'Dashboard',
              ),

              /// Settings
              BottomNavigationBarItem(
                activeIcon: _buildActiveIcon('assets/svg/Settings.svg'),
                icon: SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: SvgPicture.asset(
                    'assets/svg/Settings.svg',
                  ),
                ),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget get _buildChargingStatusButton {
    return StreamBuilder<BoxEvent>(
      stream: ConnectHiveSessionData.watchIsChargingStarted,
      builder: (context, snapshot) {
        return StreamBuilder(
          stream:
              Stream.periodic(Duration(seconds: 10)).asyncMap((i) => stat()),
          builder: (context, snapshot) {
            return Container(
                margin: EdgeInsets.only(top: 8.0),
                padding: EdgeInsets.all(2.sp),
                decoration: BoxDecoration(
                  color: (mapResponse['status'].toString() == 'true')
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).unselectedWidgetColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed:
                      // (){
                      //   print(mapResponse["status"]+"mkakdfmadsf");
                      // },
                      (mapResponse['status'].toString() == "true")
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StopChargingScreen(
                                    chargingStartedDetails:
                                        ConnectHiveSessionData
                                            .getChargingStartedDetails,
                                    chargingScheduledDetails:
                                        ConnectHiveSessionData
                                            .getChargingScheduledDetails,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainScreen()));
                            },
                  /*onPressed:
                (ConnectHiveSessionData.getIsChargingStarted ==
                            true ||
                        ConnectHiveSessionData.getIsChargingScheduled == true)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StopChargingScreen(
                              chargingStartedDetails: ConnectHiveSessionData
                                  .getChargingStartedDetails,
                              chargingScheduledDetails: ConnectHiveSessionData
                                  .getChargingScheduledDetails,
                            ),
                          ),
                        );
                      }
                    : null,*/
                  icon: SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: SvgPicture.asset(
                      'assets/svg/Battery.svg',
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ));
          },
        );
      },
    );
  }

  Widget get _buildFabButton {
    return ValueListenableBuilder(
      valueListenable: _pageIndexNotifier,
      builder: (context, index, _) {
        switch (index) {
          case 0:
            return _buildHomeViewType;
          default:
            return Container();
        }
      },
    );
  }

  Widget get _buildHomeViewType {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ValueListenableBuilder<HomeViewType>(
        valueListenable: _homeViewTypeNotifier,
        builder: (context, viewType, _) {
          return ToggleButtons(
            color: Theme.of(context).primaryColor,
            selectedColor: Color(0xffFFFFFF),
            fillColor: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10.0),
            onPressed: (index) {
              _homeViewTypeNotifier.value =
                  HomeViewType.values.elementAt(index);
              for (int i = 0; i < _isHomeViewType.length; i++) {
                if (i == index) {
                  _isHomeViewType[i] = true;
                } else {
                  _isHomeViewType[i] = false;
                }
              }
            },
            isSelected: _isHomeViewType,
            children: [
              Container(
                padding: EdgeInsets.all(5.sp),
                child: Icon(
                  Icons.place,
                  size: 20.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.sp),
                child: Icon(
                  Icons.list_outlined,
                  size: 20.sp,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveIcon(String assetPath) {
    return SizedBox(
      width: 22.sp,
      height: 22.sp,
      child: SvgPicture.asset(
        assetPath,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    _pageIndexNotifier.dispose();
    _homeViewTypeNotifier.dispose();
    super.dispose();
  }
}
