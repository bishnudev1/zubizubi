import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/services/appwrite_services.dart';
import 'package:zubizubi/services/auth_services.dart';

import 'data/models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  var userBox = await Hive.openBox<User>('userBox');
  log("UserBox is open: ${userBox.isOpen}, UserBox is empty: ${userBox.isEmpty}, UserBox length: ${userBox.length}, UserBox values: ${userBox.values}");
  setupLocator();
  locator<AppwriteServices>();
  await locator<AppwriteServices>().init();
  locator<AuthServices>();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: navigatorKey,
      title: 'ZubiZubi',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorSchemeSeed: Colors.pinkAccent,
      ),
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
    );
  }
}
