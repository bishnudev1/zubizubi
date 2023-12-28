import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SplashViewModel extends ReactiveViewModel {
  // final deepLinkServices = locator<DeepLinkServices>();

  init(BuildContext context) async {
    if (!Beamer.of(context)
        .beamingHistory
        .first
        .history
        .first
        .routeInformation
        .uri
        .toString()
        .startsWith("/share")) {
      Future.delayed(const Duration(seconds: 3), () {
        // router.go(Routes.homeScreen.path);

        Beamer.of(context).beamToNamed('/home');
      });
    }
  }
}
