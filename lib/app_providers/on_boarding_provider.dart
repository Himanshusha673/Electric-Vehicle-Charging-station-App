import 'package:flutter/material.dart';

class OnBoardingProvider extends ChangeNotifier {}

/// SignIn Service
class SignInProvider extends ChangeNotifier {
  /// Sign In
  String? email;
  String? password;

  /// Sign In Validation
  Future signInValidation({bool notify = false, Map? validateError}) async {
    email = validateError!['email'];
    password = validateError['password'];
    if (notify) {
      notifyListeners();
    }
  }

  /// Email
  Future setEmail(String input) async {
    email = input;
    notifyListeners();
  }

  /// Password
  Future setPassword(String input) async {
    password = input;
    notifyListeners();
  }
}

/// SignUp Service
class SignUpProvider extends ChangeNotifier {
  /// Sign Up
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;

  /// Sign Up Validation
  Future signUpValidation({bool notify = false, Map? validateError}) async {
    firstName = validateError!['firstName'];
    lastName = validateError['lastName'];
    email = validateError['email'];
    password = validateError['password'];
    confirmPassword = validateError['confirmPassword'];
    if (notify) {
      notifyListeners();
    }
  }

  /// First Name
  Future setFirstName(String input) async {
    firstName = input;
    notifyListeners();
  }

  /// Last Name
  Future setLastName(String input) async {
    lastName = input;
    notifyListeners();
  }

  /// Email
  Future setEmail(String input) async {
    email = input;
    notifyListeners();
  }

  /// Password
  Future setPassword(String input) async {
    password = input;
    notifyListeners();
  }

  /// Confirm Password
  Future setConfirmPassword(String input) async {
    confirmPassword = input;
    notifyListeners();
  }
}

/// ForgotPassword service
class ForgotPasswordProvider extends ChangeNotifier {
  ///Forgot password
  String? email;
  String? verificationCode;
  String? password;
  String? confirmPassword;

  /// Email
  Future setEmail(String input) async {
    email = input;
    notifyListeners();
  }

  /// verification code
  Future setVerificationCode(String input) async {
    verificationCode = input;
    notifyListeners();
  }

  /// Password
  Future setPassword(String input) async {
    password = input;
    notifyListeners();
  }

  /// Confirm Password
  Future setConfirmPassword(String input) async {
    confirmPassword = input;
    notifyListeners();
  }

  Future forgotPasswordValidation(
      {bool notify = false, Map? validateError}) async {
    email = validateError!['email'];
    verificationCode = validateError['verificationCode'];
    password = validateError['password'];
    confirmPassword = validateError['confirmPassword'];
    if (notify) {
      notifyListeners();
    }
  }
}
