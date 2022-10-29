import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../app_screens/home/start_charging_screen.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_utils/app_functions.dart';

Future _searchChargePointByPostCode(String query) async {
  var res = await AppApiCollection.getChargeBoxByPostCode(query: query);
  return res;
}

class HomeScreenListViewSearch extends SearchDelegate {
  final double myLatitude;
  final double myLongitude;

  HomeScreenListViewSearch({
    required this.myLatitude,
    required this.myLongitude,
  });

  Map? data = {};

  String calculateDistance({latitude, longitude}) {
    return padQuotes(
      convertToDistance(
        Geolocator.distanceBetween(
          myLatitude,
          myLongitude,
          double.tryParse(latitude.toString())!,
          double.tryParse(longitude.toString())!,
        ),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search by post Code';

  @override
  TextStyle get searchFieldStyle => TextStyle(
        color: const Color(0xff252a34).withOpacity(0.6),
        fontFamily: 'Rubik',
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        InkWell(
          onTap: () {
            query = '';
          },
          borderRadius: BorderRadius.circular(40.0),
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Icon(
              Icons.clear_outlined,
              color: Colors.black,
            ),
          ),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        padding: EdgeInsets.all(2.0),
        child: Icon(
          Icons.arrow_back_outlined,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (data != null) {
      if (numeric(data!['totalCount']) > 0) {
        List details = data!['details'];
        return ListView.separated(
          shrinkWrap: true,
          controller: ScrollController(),
          itemCount: numeric(details.length),
          itemBuilder: (context, index) {
            Map detailsData = details[index];
            return Padding(
              padding: EdgeInsets.only(
                top: (index == 0) ? 20.0 : 0.0,
              ),
              child: InkWell(
                onTap: () {
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
                splashColor: Theme.of(context).primaryColor,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        padQuotes(detailsData['street']),
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(height: 10),
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
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                padQuotes(myLatitude).isNotEmpty &&
                                        padQuotes(myLongitude).isNotEmpty
                                    ? calculateDistance(
                                        latitude: detailsData['latitude'],
                                        longitude: detailsData['longitude'],
                                      )
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
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 20,
              child: Divider(),
            );
          },
        );
      }
      return Center(child: Text('No Records Found'));
    } else {
      return Center(child: Text('No Records Found'));
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    return FutureBuilder(
      future: _searchChargePointByPostCode(query),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              data = snapshot.data as Map?;
              if (numeric(data!['totalCount']) > 0) {
                List details = data!['details'];
                return ListView.separated(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  itemCount: numeric(details.length),
                  itemBuilder: (context, index) {
                    Map detailsData = details[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        top: (index == 0) ? 20.0 : 0.0,
                      ),
                      child: InkWell(
                        onTap: () {
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
                        splashColor: Theme.of(context).primaryColor,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    padQuotes(detailsData['city']),
                                    textAlign: TextAlign.left,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                padQuotes(detailsData['street']),
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.my_location_outlined,
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        padQuotes(myLatitude).isNotEmpty &&
                                                padQuotes(myLongitude)
                                                    .isNotEmpty
                                            ? calculateDistance(
                                                latitude:
                                                    detailsData['latitude'],
                                                longitude:
                                                    detailsData['longitude'],
                                              )
                                            : 'unknown',
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Text(
                                      padQuotes(
                                          detailsData['connector_description']),
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 20,
                      child: Divider(),
                    );
                  },
                );
              }
              return Center(child: Text('No Records Found'));
            } else {
              return Center(child: Text('No Records Found'));
            }
          case ConnectionState.waiting:
            return LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor,
              ),
              backgroundColor: Colors.transparent,
            );
          default:
            return Container();
        }
      },
    );
  }
}