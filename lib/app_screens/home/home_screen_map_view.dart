import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';

import '../../app_providers/home/home_screen_map_view_provider.dart';
import '../../app_services/app_api_collection.dart';
import '../../app_services/user_location_service.dart';
import '../../app_utils/app_functions.dart';
import 'start_charging_screen.dart';

class HomeScreenMapView extends StatefulWidget {
  final GlobalKey<ScaffoldState>? mainScaffoldKey;

  const HomeScreenMapView({
    Key? key,
    this.mainScaffoldKey,
  }) : super(key: key);

  @override
  _HomeScreenMapViewState createState() => _HomeScreenMapViewState();
}

class _HomeScreenMapViewState extends State<HomeScreenMapView> {
  final Set<Marker> _markers = <Marker>{};
  final Completer<GoogleMapController> _googleMapController = Completer();

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(52.28505110,
        -1.52505540), //LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final UserLocationService _userLocationService = UserLocationService.instance;

  Future _getChargePointStations() async {
    var res = await AppApiCollection.getStations();

    if (res != null && numeric(res['totalCount']) > 0) {
      Map data = {};
      List details = [];
      data = res as Map;
      details = data['details'] as List;

      /// removing unknown location from list
      details.retainWhere((data) {
        // debugPrint("removing unknown location from list:\t$data");
        return double.tryParse(padQuotes(data['latitude'])) != null &&
            double.tryParse(padQuotes(data['longitude'])) != null;
      });

      if (details.isNotEmpty) {
        Location location = Location();
        bool isLocationServiceEnabled;
        LocationPermission checkPermission;
        isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
        // debugPrint("isLocationServiceEnabled:\t$isLocationServiceEnabled");

        switch (isLocationServiceEnabled) {

          /// Location Service enabled
          case true:
            checkPermission = await Geolocator.checkPermission();
            // debugPrint("checkPermission:\t$checkPermission");

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
            } else {
              // return;
            }
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
              } else {
                // return;
              }
            } else {
              // return;
            }

            break;
          default:
            // return;
            break;
        }

        isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
        checkPermission = await Geolocator.checkPermission();
        if (isLocationServiceEnabled == true &&
            (checkPermission == LocationPermission.whileInUse ||
                checkPermission == LocationPermission.always)) {
          await _performAction(details);
        } else {
          /// add Marker
          for (int index = 0; index < details.length; index++) {
            await _addMarker(
              index,
              details[index],
            );
          }
          Provider.of<HomeScreenMapViewProvider>(context, listen: false)
              .setMarkers(markers: _markers, notify: true);
          // return;
        }
      }
    }
    return res;
  }

  Future _performAction(List details) async {
    // debugPrint("performAction");
    await _userLocationService.initialize();

    Provider.of<HomeScreenMapViewProvider>(context, listen: false)
        .setMyLocation(
      latitude: _userLocationService.getPosition!.latitude,
      longitude: _userLocationService.getPosition!.longitude,
    );

    /// inserting distance
    // debugPrint("inserting distance");
    details.map((element) {
      Map<String, dynamic> data = element;
      (element as Map<String, dynamic>).addAll({
        'distance':
            Provider.of<HomeScreenMapViewProvider>(context, listen: false)
                .calculateDistance(
          destinationLatitude: data['latitude'],
          destinationLongitude: data['longitude'],
        ),
      });
    }).toList();

    // debugPrint("sort location according to distance");

    /// sort location according to distance
    Provider.of<HomeScreenMapViewProvider>(context, listen: false)
        .setStationList(stationList: details);
    Provider.of<HomeScreenMapViewProvider>(context, listen: false)
        .sortStationList(
      notify: true,
    );

    // debugPrint("add Marker");

    /// add Marker
    for (int index = 0; index < details.length; index++) {
      await _addMarker(
        index,
        details[index],
      );
    }
    Provider.of<HomeScreenMapViewProvider>(context, listen: false)
        .setMarkers(markers: _markers, notify: true);

    /// go to Location
    double distance = details[0]['distance'];
    // debugPrint("distance:\t$distance");
    if (distance > 0) {
      _goToLocation(
        latitude: double.parse(padQuotes(details[0]['latitude'])),
        longitude: double.parse(padQuotes(details[0]['longitude'])),
      );
    } else {
      _gotToCurrentLocation();
    }
  }

  Future _getChargeBoxes({
    required int stationId,
  }) async {
    var res = await AppApiCollection.getChargeBoxesByStation(
      stationId: padQuotes(stationId),
    );
    return res;
  }

  _addMarker(int index, Map details) async {
    final int targetWidth = 65.sp.toInt();
    final Uint8List markerIcon = await getBytesFromAsset(
        'assets/images/greenPointEV_map.png', targetWidth);
    _markers.add(
      Marker(
        markerId: MarkerId(cNumeric(details['address_pk'])),
        position: LatLng(
          double.parse(padQuotes(details['latitude'])),
          double.parse(padQuotes(details['longitude'])),
        ),
        infoWindow: InfoWindow(
          title: padQuotes(details['city']),
        ),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        onTap: () async {
          await _showChargeBoxes(
            context: context,
            stationId: numeric(details['address_pk']),
          );
        },
      ),
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _goToLocation({
    required double? latitude,
    required double? longitude,
  }) async {
    final GoogleMapController _controller = await _googleMapController.future;
    if (latitude != null && longitude != null) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 18,
          ),
        ),
      );
    }
  }

  Future<void> _gotToCurrentLocation() async {
    await _userLocationService.initialize();
    await _goToLocation(
      latitude: _userLocationService.getPosition!.latitude,
      longitude: _userLocationService.getPosition!.longitude,
    );
  }

  @override
  void initState() {
    debugPrintInit(widget.runtimeType);
    super.initState();
    _markers.clear();
    _getChargePointStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Consumer<HomeScreenMapViewProvider>(
          builder: (context, service, _) {
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    trafficEnabled: true,
                    markers: service.getMarkers,
                    onMapCreated: (GoogleMapController controller) {
                      _googleMapController.complete(controller);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      child: Container(
                        padding: EdgeInsets.all(8.0.sp),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.my_location_outlined,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        Location location = Location();
                        bool isLocationServiceEnabled;
                        LocationPermission checkPermission;
                        isLocationServiceEnabled =
                            await Geolocator.isLocationServiceEnabled();
                        // debugPrint("isLocationServiceEnabled:\t$isLocationServiceEnabled");

                        switch (isLocationServiceEnabled) {

                          /// Location Service enabled
                          case true:
                            checkPermission =
                                await Geolocator.checkPermission();
                            // debugPrint("checkPermission:\t$checkPermission");

                            /// LocationPermission.denied or LocationPermission.deniedForever
                            if (checkPermission ==
                                    LocationPermission.deniedForever ||
                                checkPermission == LocationPermission.denied) {
                              var res = await showLocationPermissionDialog(
                                context: context,
                                locationPermission: checkPermission,
                              );
                              switch (res) {
                                case 'continue':
                                  checkPermission =
                                      await Geolocator.requestPermission();
                                  break;
                                case 'settings':
                                  await Geolocator.openAppSettings();
                                  break;
                              }
                            }

                            /// LocationPermission.whileInUse or LocationPermission.always
                            else if (checkPermission ==
                                    LocationPermission.whileInUse ||
                                checkPermission == LocationPermission.always) {
                              break;
                            } else {
                              return;
                            }
                            break;

                          /// Location Service not enabled
                          case false:
                            var res = await showLocationEnableDialog(
                                context: context);
                            if (res == 'continue') {
                              isLocationServiceEnabled =
                                  await location.requestService();
                            }
                            if (isLocationServiceEnabled == true) {
                              checkPermission =
                                  await Geolocator.checkPermission();

                              /// LocationPermission.denied or LocationPermission.deniedForever
                              if (checkPermission ==
                                      LocationPermission.deniedForever ||
                                  checkPermission ==
                                      LocationPermission.denied) {
                                var res = await showLocationPermissionDialog(
                                  context: context,
                                  locationPermission: checkPermission,
                                );
                                switch (res) {
                                  case 'continue':
                                    checkPermission =
                                        await Geolocator.requestPermission();
                                    break;
                                  case 'settings':
                                    await Geolocator.openAppSettings();
                                    break;
                                }
                              }

                              /// LocationPermission.whileInUse or LocationPermission.always
                              else if (checkPermission ==
                                      LocationPermission.whileInUse ||
                                  checkPermission ==
                                      LocationPermission.always) {
                                break;
                              } else {
                                return;
                              }
                            } else {
                              return;
                            }

                            break;
                          default:
                            return;
                        }

                        isLocationServiceEnabled =
                            await Geolocator.isLocationServiceEnabled();
                        checkPermission = await Geolocator.checkPermission();
                        if (isLocationServiceEnabled == true &&
                            (checkPermission == LocationPermission.whileInUse ||
                                checkPermission == LocationPermission.always)) {
                          _gotToCurrentLocation();
                        } else {
                          return;
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      /* floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: FittedBox(
          alignment: Alignment.center,
          fit: BoxFit.contain,
          child: Container(
            padding: EdgeInsets.all(8.0.sp),
            child: Icon(
              Icons.my_location_outlined,
              size: 20.sp,
            ),
          ),
        ),
        onPressed: () async {
          Location location = Location();
          bool isLocationServiceEnabled;
          LocationPermission checkPermission;
          isLocationServiceEnabled =
              await Geolocator.isLocationServiceEnabled();
          debugPrint("isLocationServiceEnabled:\t$isLocationServiceEnabled");

          switch (isLocationServiceEnabled) {

            /// Location Service enabled
            case true:
              checkPermission = await Geolocator.checkPermission();
              debugPrint("checkPermission:\t$checkPermission");

              /// LocationPermission.denied or LocationPermission.deniedForever
              if (checkPermission == LocationPermission.deniedForever ||
                  checkPermission == LocationPermission.denied) {
                var res = await showLocationPermissionDialog(
                  context: context,
                  locationPermission: checkPermission,
                );
                switch (res) {
                  case "continue":
                    checkPermission = await Geolocator.requestPermission();
                    break;
                  case "settings":
                    await Geolocator.openAppSettings();
                    break;
                }
              }

              /// LocationPermission.whileInUse or LocationPermission.always
              else if (checkPermission == LocationPermission.whileInUse ||
                  checkPermission == LocationPermission.always) {
                break;
              } else {
                return;
              }
              break;

            /// Location Service not enabled
            case false:
              var res = await showLocationEnableDialog(context: context);
              if (res == "continue") {
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
                    case "continue":
                      checkPermission = await Geolocator.requestPermission();
                      break;
                    case "settings":
                      await Geolocator.openAppSettings();
                      break;
                  }
                }

                /// LocationPermission.whileInUse or LocationPermission.always
                else if (checkPermission == LocationPermission.whileInUse ||
                    checkPermission == LocationPermission.always) {
                  break;
                } else {
                  return;
                }
              } else {
                return;
              }

              break;
            default:
              return;
              break;
          }

          isLocationServiceEnabled =
              await Geolocator.isLocationServiceEnabled();
          checkPermission = await Geolocator.checkPermission();
          if (isLocationServiceEnabled == true &&
              (checkPermission == LocationPermission.whileInUse ||
                  checkPermission == LocationPermission.always)) {
            _gotToCurrentLocation();
          } else {
            return;
          }
        },
      ),*/
    );
  }

  Future _showChargeBoxes({
    required BuildContext context,
    required int stationId,
  }) async {
    Future _future = _getChargeBoxes(stationId: stationId);
    return await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.all(8.0),
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Loading Data',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      Map<String, dynamic>? data =
                          snapshot.data as Map<String, dynamic>?;
                      if (numeric(data!['totalCount']) > 0) {
                        return Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            controller: ScrollController(),
                            physics: BouncingScrollPhysics(),
                            itemCount: numeric(data['totalCount']),
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            itemBuilder: (context, index) {
                              Map details = data['details'][index];
                              return InkWell(
                                onTap: () {
                                  /*Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StopChargingScreen(
                                                details: details,
                                                transactionId: null),
                                      ));*/
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StartChargingScreen(
                                          chargeBoxId: details['charge_box_id'],
                                          chargeType: details['charge_type'], 
                                          tariffData: details['tariff'],
                                        ),
                                      ));
                                },
                                splashColor: Theme.of(context).primaryColor,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            padQuotes(details['city']),
                                            textAlign: TextAlign.left,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
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
                                      SizedBox(height: 8),
                                      Text(
                                        padQuotes(details['street']),
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              padQuotes(details[
                                                  'connector_description']),
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                Divider(height: 0.0),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text('Charge boxes not available'),
                        );
                      }
                    }
                    return Container();
                  default:
                    return Container();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    debugPrintDispose(widget.runtimeType);
    super.dispose();
  }
}