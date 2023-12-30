import 'dart:developer';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zubizubi/views/home/home_screen.dart';
import 'package:zubizubi/views/login/login_screen.dart';
import 'package:zubizubi/views/profile/profile_screen.dart';
import 'package:zubizubi/views/search/search_screen.dart';
import 'package:zubizubi/views/splash/splash_screen.dart';


final GlobalKey navigatorKey = GlobalKey();

final routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': (context, state, data) => const SplashScreen(),
      '/home': (context, state, data) => const HomeScreen(),
      '/login': (context, state, data) => const LoginScreen(),
      '/profile': (context, state, data) => const ProfileScreen(),
      '/search': (context, state, data) => const SearchScreen(),
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