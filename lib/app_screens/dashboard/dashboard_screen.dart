import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_common_widgets/shimmers/shimmers.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';

class DashBoardScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? mainScaffoldKey;

  const DashBoardScreen({
    Key? key,
    this.mainScaffoldKey,
  }) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with TickerProviderStateMixin {
  Future? _future;

  TabController? _tabController;

  final List<String> _tabList = ['24 Hr', '30 Days', '1 Year'];

  final ValueNotifier<int> _categoryNotifier = ValueNotifier<int>(0);
  final StreamController _streamController = StreamController();

  Future _getDashboardData() async {
    String date;
    switch (_categoryNotifier.value) {
      case 0:
        date = '1';
        break;
      case 1:
        date = '30';
        break;
      case 2:
        date = '365';
        break;
      default:
        date = '1';
        break;
    }
    var res = await AppApiCollection.getDashBoard(
      email: ConnectHiveSessionData.getEmail,
      date: date,
    );
    return res;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _tabController = TabController(length: _tabList.length, vsync: this);
    _future = _getDashboardData();
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
              _buildBody,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildAppBar {
    return BuildAppBar(
      title: 'Dashboard',
      leading: (widget.mainScaffoldKey != null) ? Container() : null,
    );
  }

  Widget get _buildBody {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        controller: ScrollController(),
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        children: <Widget>[
          SizedBox(height: 10),
          _buildTabBar,
          _buildTabBody,
        ],
      ),
    );
  }

  Widget get _buildTabBody {
    return ValueListenableBuilder(
      valueListenable: _categoryNotifier,
      builder: (context, notifierValue, _) {
        return FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasData) {
                  Map<String, dynamic>? data =
                      snapshot.data as Map<String, dynamic>?;
                  Map details = data!['details'];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      /*SizedBox(height: 20),
                          Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 10.0),
                              height: 250,
                              width: double.infinity,
                              decoration: const BoxDecoration(),
                              child: BarChart(
                                GraphData.dashboardScreenGraphByYear(
                                  context: context,
                                  details: details,
                                ),
                              ),
                            ),
                          ),*/
                      SizedBox(height: 20),
                      _buildCard(
                        value: padQuotes(
                            roundDouble(details['sum_kwh']).toStringAsFixed(2)),
                        imagePath: 'assets/svg/Battery.svg',
                        unit: 'kWh',
                      ),
                      SizedBox(height: 10),
                      _buildCard(
                        value: '\u{00A3}' +
                            padQuotes(roundDouble(details['cost'])
                                .toStringAsFixed(2)),
                        imagePath: 'assets/svg/three-stacks-of-coins.svg',
                        unit: 'Cost',
                      ),
                      SizedBox(height: 10),
                      _buildCard(
                        value: padQuotes(roundDouble(details['sum_co2'])
                                .toStringAsFixed(2)) +
                            'kg',
                        imagePath: 'assets/svg/Leaf.svg',
                        unit: 'CO' '\u{2082}',
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*SizedBox(height: 20),
                    Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10.0),
                        height: 250,
                        width: double.infinity,
                        decoration: const BoxDecoration(),
                        child: BarChart(
                          GraphData.dashboardScreenGraphByYear(
                            context: context,
                            details: details,
                          ),
                        ),
                      ),
                    ),*/
                      SizedBox(height: 20),
                      _buildCard(
                        value: '0.0',
                        imagePath: 'assets/svg/Battery.svg',
                        unit: 'kWh',
                      ),
                      SizedBox(height: 10),
                      _buildCard(
                        value: '\u{00A3}' '0.0',
                        imagePath: 'assets/svg/three-stacks-of-coins.svg',
                        unit: 'Cost',
                      ),
                      SizedBox(height: 10),
                      _buildCard(
                        value: '0kg',
                        imagePath: 'assets/svg/Leaf.svg',
                        unit: 'CO' '\u{2082}',
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }
              case ConnectionState.waiting:
                return _buildCircularLoader;
              default:
                return Container();
            }
          },
        );
      },
    );
  }

  Widget get _buildCircularLoader {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget get _buildShimmerLoader {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        _buildShimmerCard(
          imagePath: 'assets/svg/Battery.svg',
          unit: 'kWh',
        ),
        SizedBox(height: 10),
        _buildShimmerCard(
          imagePath: 'assets/svg/three-stacks-of-coins.svg',
          unit: 'Cost',
        ),
        SizedBox(height: 10),
        _buildShimmerCard(
          imagePath: 'assets/svg/Leaf.svg',
          unit: 'CO' '\u{2082}',
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCard({
    required String value,
    required String imagePath,
    required String unit,
  }) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /*Align(
                alignment: Alignment.center,
                child: Container(
                  // width: 50,
                  height: 50,
                  child: SvgPicture.asset(
                    padQuotes(imagePath),
                  ),
                ),
              ),*/
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    padQuotes(value),
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    width: 50.sp,
                    height: 50.sp,
                    child: SvgPicture.asset(
                      padQuotes(imagePath),
                      color: Color(0xff7F7F7F),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    padQuotes(unit),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({
    required String imagePath,
    required String unit,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: BuildShimmer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: BuildShimmerContainer(width: 10),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  width: 50.sp,
                  height: 50.sp,
                  child: SvgPicture.asset(
                    padQuotes(imagePath),
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  padQuotes(unit),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget _buildCard({
    String value,
    String unit,
  }) {
    return Builder(
      builder: (context) {
        return Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  padQuotes(value),
                  style: Theme.of(context).textTheme.headline1,
                ),
                Text(
                  padQuotes(unit),
                  style: Theme.of(context).textTheme.headline1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/

  Widget get _buildTabBar {
    return TabBar(
      controller: _tabController,
      indicatorWeight: 4,
      labelPadding: EdgeInsets.symmetric(vertical: 5.0),
      onTap: (index) {
        _categoryNotifier.value = index;
        _future = _getDashboardData();
      },
      tabs: List.generate(_tabList.length, (index) {
        return Text(
          padQuotes(_tabList[index]),
          style: Theme.of(context).textTheme.headline6!.copyWith(
              // height: 0.8,
              ),
        );
      }),
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    _streamController.close();
    _categoryNotifier.dispose();
    super.dispose();
  }
}
