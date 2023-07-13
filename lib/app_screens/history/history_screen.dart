import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_common_widgets/shimmers/shimmers.dart';
import '../../app_resources/pagination/pagination_stream.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';
import '../../app_utils/connect/hive/connect_hive.dart';
import '../../app_utils/widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? mainScaffoldKey;

  const HistoryScreen({
    Key? key,
    this.mainScaffoldKey,
  }) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future _getHistory(int pageIndex) async {
    var res = await AppApiCollection.getHistoryDetails(
      email: ConnectHiveSessionData.getEmail,
      pageIndex: pageIndex,
    );
    if (res != null) {
      Map data = res;
      List details = data['data'];
      ConnectHiveNetworkData.setHistory(details);
    }
    return res;
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('${widget.runtimeType} didChangeDependencies');
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
                child: PaginationStreamListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  initialData: ConnectHiveNetworkData.getHistory,
                  pageFetch: _getHistory,
                  onLoading: _buildShimmerOnLoading,
                  onPageLoading: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 20.sp,
                        width: 20.sp,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                  onError: (index) {
                    return Center(
                      child: Icon(Icons.refresh),
                    );
                  },
                  onEmpty: Center(
                    child: Text('No History Available'),
                  ),
                  itemBuilder: (context, index, snapshot) {
                    Map<String, dynamic>? detailsData =
                        snapshot as Map<String, dynamic>?;
                    return _buildHistoryData(detailsData!);
                  },
                  separatorBuilder: (context, index, snapshot) =>
                      Divider(height: 0.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildCircularOnLoading {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 20.sp,
          width: 20.sp,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  Widget get _buildShimmerOnLoading {
    return BuildShimmer(
      child: ListView.separated(
        itemCount: 20,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    BuildShimmerContainer(width: 100),
                    SizedBox(width: 10),
                    BuildShimmerContainer(width: 80),
                    SizedBox(width: 10),
                    BuildShimmerContainer(width: 80),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    BuildShimmerContainer(width: 150),
                    BuildShimmerContainer(width: 50),
                    BuildShimmerContainer(width: 50),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    BuildShimmerContainer(width: 120),
                    BuildShimmerContainer(width: 80),
                  ],
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(height: 0.0),
      ),
    );
  }

  Widget _buildHistoryData(Map<String, dynamic> detailsData) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
                text: (isLongDateFormat(detailsData['start_timestamp']))
                    ? convertToCompanyDateFormat(
                        pattern: 'dd/MM/yyyy',
                        date:
                            DateTime.parse("${detailsData['start_timestamp']}")
                                .add(DateTime.now().timeZoneOffset)
                                .toString(),
                      )
                    : '',
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  TextSpan(text: ' - '),
                  TextSpan(
                      text: (isLongDateFormat(detailsData['start_timestamp']))
                          ? convertToCompanyDateFormat(
                              pattern: 'HH:MM',
                              date: DateTime.parse(
                                      "${detailsData['start_timestamp']}")
                                  .add(DateTime.now().timeZoneOffset)
                                  .toString(),
                            )
                          : ''),
                  TextSpan(text: ' -- '),
                  TextSpan(
                      text: (isLongDateFormat(detailsData['stop_timestamp']))
                          ? convertToCompanyDateFormat(
                              pattern: 'HH:MM',
                              date: DateTime.parse(
                                      "${detailsData['stop_timestamp']}")
                                  .add(DateTime.now().timeZoneOffset)
                                  .toString(),
                            )
                          : ''),
                ]),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                padQuotes(detailsData['city']),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Text(
                padQuotes(detailsData['sumcost']).isNotEmpty
                    ? '\u{00A3}' +
                        padQuotes(roundDouble(detailsData['sumcost'])
                            .toStringAsFixed(2))
                    : 'NA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Text(
                padQuotes(detailsData['sum_kWh']).isNotEmpty
                    ? padQuotes(roundDouble(detailsData['sum_kWh'])
                            .toStringAsFixed(2)) +
                        'kWh'
                    : 'NA',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                padQuotes(detailsData['payment_method']) == 'Token ID'
                    ? 'Token ID'
                    : 'Credit Card',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Text(
                (padQuotes(detailsData['start_timestamp']).isNotEmpty &&
                        padQuotes(detailsData['stop_timestamp']).isNotEmpty)
                    ? calculateDuration(
                        startTime: padQuotes(detailsData['start_timestamp']),
                        endTime: padQuotes(detailsData['stop_timestamp']),
                      )
                    : 'NA',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _buildAppBar {
    return BuildAppBar(
      title: 'History',
      leading: (widget.mainScaffoldKey != null) ? Container() : null,
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    super.dispose();
  }
}
