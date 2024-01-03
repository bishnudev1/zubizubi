import 'dart:developer';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/auth_services.dart';
import 'package:zubizubi/utils/toast.dart';
import 'package:zubizubi/views/chats/chats_screen.dart';
import 'package:zubizubi/views/chats/room/room_screen.dart';
import 'package:zubizubi/views/followers/followers_screen.dart';
import 'package:zubizubi/views/home/home_screen.dart';
import 'package:zubizubi/views/login/login_screen.dart';
import 'package:zubizubi/views/profile/profile_screen.dart';
import 'package:zubizubi/views/search/search_screen.dart';
import 'package:zubizubi/views/splash/splash_screen.dart';

final GlobalKey navigatorKey = GlobalKey();

final _authServices = locator<AuthServices>();

BeamGuard authGuard = BeamGuard(
  pathPatterns: ["/profile", "/search", "/followers"],
  check: ((context, location) {
    final isAuth = _authServices.isSignedIn();
    if (!isAuth) {
      showToast("You need to be logged In to do that!");
    }
    return isAuth;
  }),
  replaceCurrentStack: false,
  beamToNamed: (origin, target) => "/login",
);

final routerDelegate = BeamerDelegate(
  guards: [authGuard],
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': (context, state, data) => const SplashScreen(),
      '/shell': (context, state, data) => ShellScreen(),
      //   '/home': (context, state, data) => const HomeScreen(),
      '/login': (context, state, data) => const LoginScreen(),
      //   '/followers': (context, state, data) => const FollowersScreen(),
      //   '/profile': (context, state, data) => const ProfileScreen(),
      //   '/search': (context, state, data) => const SearchScreen(),
      '/room': (context, state, data) {
        return BeamPage(
          key: const ValueKey('room'),
          popToNamed: '/shell',
          type: BeamPageType.scaleTransition,
          child: RoomScreen(key: UniqueKey(), receiver: data as Map<String, dynamic>),
        );
      },
      '/share': (context, state, data) {
        log("state.uri: ${state.uri}");
        // Use BeamPage to define custom behavior
        return BeamPage(
          key: const ValueKey('share'),
          popToNamed: '/shell',
          type: BeamPageType.scaleTransition,
          child: HomeScreen(key: UniqueKey(), shareUrl: state.uri.queryParameters['url']),
        );
      }
    },
  ),
);

class LoginLocation extends BeamLocation<BeamState> {
  LoginLocation() : super();

  @override
  List<Pattern> get pathPatterns => ['/login'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('login'),
          name: 'login',
          popToNamed: '/shell',
          child: LoginScreen(),
        ),
      ];
}

// ProfileLocation
class ProfileLocation extends BeamLocation<BeamState> {
  ProfileLocation() : super();

  @override
  List<Pattern> get pathPatterns => ['/profile'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('profile'),
          child: ProfileScreen(),
        ),
      ];
}

// SearchLocation
class SearchLocation extends BeamLocation<BeamState> {
  SearchLocation() : super();

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('search'),
          child: SearchScreen(),
        ),
      ];

  @override
  List<Pattern> get pathPatterns => [
        '/search',
      ];
}

// HomeLocation
class HomeLocation extends BeamLocation<BeamState> {
  HomeLocation() : super();

  @override
  List<Pattern> get pathPatterns => [
        '/home',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
      ];
}

// FollowersLocation
class FollowersLocation extends BeamLocation<BeamState> {
  FollowersLocation() : super();

  @override
  List<Pattern> get pathPatterns => [
        '/followers',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('followers'),
          name: 'followers',
          child: FollowersScreen(),
        ),
      ];
}

// ChatsLocation
class ChatsLocation extends BeamLocation<BeamState> {
  ChatsLocation() : super();

  @override
  List<Pattern> get pathPatterns => [
        '/chats',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('chats'),
          name: 'chats',
          child: ChatsScreen(),
        ),
      ];
}
