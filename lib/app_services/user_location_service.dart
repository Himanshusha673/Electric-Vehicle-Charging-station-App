import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationService {
  static UserLocationService? _userLocationService;
  Position? _position;

  UserLocationService._internal();

  static UserLocationService get instance {
    _userLocationService ??= UserLocationService._internal();
    return _userLocationService!;
  }

  Future<Position?> initialize() async {
    try {
      _position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      debugPrint(e.toString());
    }
    return _position;
  }

  Position? get getPosition => _position;
}
