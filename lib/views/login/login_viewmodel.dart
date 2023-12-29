import 'dart:developer';

import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/auth_services.dart';

class LoginViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  bool isLoading = false;
  loginWithFacebook() async {
    await _authServices.handleFacebookLogin();
  }

  loginWithGoogle() async {
    isLoading = true;
    notifyListeners();
    try {
      await _authServices.handleGoogleLogin();
    } catch (e) {
      log(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }
}
