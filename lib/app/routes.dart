import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zubizubi/views/home/home_screen.dart';
import 'package:zubizubi/views/splash/splash_screen.dart';


final routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': (context, state, data) => const SplashScreen(),
      '/home': (context, state, data) => const HomeScreen(),
      '/share': (context, state, data) {
        log("state.uri: ${state.uri}");
        // Use BeamPage to define custom behavior
        return BeamPage(
          key: const ValueKey('share'),
          //   popToNamed: '/',
          type: BeamPageType.scaleTransition,
          child: HomeScreen(key: UniqueKey(), shareUrl: state.uri.queryParameters['url']),
        );
      }
    },
  ),
);