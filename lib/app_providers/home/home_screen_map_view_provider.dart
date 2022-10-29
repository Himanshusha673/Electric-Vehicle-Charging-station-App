import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreenMapViewProvider extends ChangeNotifier {
  double? _myLatitude;
  double? _myLongitude;
  List _stationList = [];
  Set<Marker> _markers = {};

  /// get My Latitude
  double? get getMyLatitude {
    return _myLatitude;
  }

  /// get My Longitude
  double? get getMyLongitude {
    return _myLongitude;
  }

  /// set My Location
  Future setMyLocation({
    required double latitude,
    required double longitude,
    bool notify = false,
  }) async {
    _myLatitude = latitude;
    _myLongitude = longitude;
    if (notify) {
      notifyListeners();
    }
  }

  /// get Station List
  List get getStationList {
    return _stationList;
  }

  /// set  Station List
  Future setStationList({
    required List stationList,
    bool notify = false,
  }) async {
    _stationList = stationList;
    if (notify) {
      notifyListeners();
    }
  }

  /// get Markers
  get getMarkers {
    return _markers;
  }

  /// set Markers
  Future setMarkers({
    required Set<Marker> markers,
    bool notify = false,
  }) async {
    _markers = markers;
    if (notify) {
      notifyListeners();
    }
  }

  /// calculate distance
  double calculateDistance({
    required destinationLatitude,
    required destinationLongitude,
  }) {
    return Geolocator.distanceBetween(
      _myLatitude!,
      _myLongitude!,
      double.parse(destinationLatitude.toString()),
      double.parse(destinationLongitude.toString()),
    );
  }

  /// sort Station List
  sortStationList({
    bool notify = false,
  }) {
    _stationList.sort(
      (a, b) {
        return double.parse(a['distance'].toString())
            .compareTo(double.parse(b['distance'].toString()));
      },
    );
    if (notify) {
      notifyListeners();
    }
  }
}
