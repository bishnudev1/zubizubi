import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';

BottomNavigationBar bottomNavigationBar(BuildContext context) {
  int currentIndex = 0; // Initialize the current index
  final currentRoute = ModalRoute.of(context)!.settings.name;
  return BottomNavigationBar(
    showSelectedLabels: false,
    showUnselectedLabels: false,
    elevation: 0,
    backgroundColor: Colors.black,
    type: BottomNavigationBarType.fixed,
    currentIndex: currentIndex, // Set the current index
    onTap: (index) {
      currentIndex = index; // Update the current index
      switch (index) {
        case 0:
          if (currentRoute != "/home-screen") {
            Beamer.of(context).beamToNamed('/home');
          }
          break;
        case 3:
          if (currentRoute != "/profile") {
            Beamer.of(context).beamToNamed('/profile');
          }
          break;
      }
    },
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: FaIcon(
          FontAwesomeIcons.house,
          color: Colors.white,
          size: 21,
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: FaIcon(
          FontAwesomeIcons.magnifyingGlass,
          color: Colors.white,
          size: 21,
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: FaIcon(
          FontAwesomeIcons.video,
          color: Colors.white,
          size: 21,
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: FaIcon(
          FontAwesomeIcons.user,
          color: Colors.white,
          size: 21,
        ),
        label: '',
      ),
    ],
  );
}
