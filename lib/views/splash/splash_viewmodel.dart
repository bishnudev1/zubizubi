import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/services/auth_services.dart';

class SplashViewModel extends ReactiveViewModel {
  // final deepLinkServices = locator<DeepLinkServices>();
  final _authServices = locator<AuthServices>();

  init(BuildContext context) async {
    final currentUser = await _authServices.getCurrentUser();

    // log("SPlash Screen Current User: $currentUser");
    if (!routerDelegate.beamingHistory.first.history.first.routeInformation.uri
        .toString()
        .startsWith("/share")) {
      
      if(routerDelegate.currentBeamLocation.state.routeInformation.uri.toString().startsWith("/share")){
        log("Current Beam Location: ${routerDelegate.currentBeamLocation.state.routeInformation.uri}");
        return;
      }

      Future.delayed(const Duration(seconds: 3), () {
        // router.go(Routes.homeScreen.path);
        log("SPlash Screen Current User: $currentUser");

        log("Current User: $currentUser");

        if (currentUser == null) {
          Beamer.of(context).beamToNamed('/login');
        } else {
          Beamer.of(context).beamToNamed('/shell');
        }
      });
    }
  }
}
