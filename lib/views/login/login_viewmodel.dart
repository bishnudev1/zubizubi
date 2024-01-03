import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/services/auth_services.dart';
import 'package:zubizubi/utils/toast.dart';

class LoginViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  bool isLoading = false;
  loginWithFacebook() async {
    await _authServices.handleFacebookLogin();
  }

  loginWithGoogle(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authServices.handleGoogleLogin(context);
    } catch (e) {
      log(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  continueAsGuest() {
    if (routerDelegate.currentBeamLocation.state.routeInformation.uri.toString().startsWith("/shell")) {
      log("Current Beam Location: ${routerDelegate.currentBeamLocation.state.routeInformation.uri}");
      showToast("You are already logged in as a guest!");
      return;
    }
    routerDelegate.beamToNamed('/shell');
  }
}
