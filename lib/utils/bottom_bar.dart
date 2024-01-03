import 'dart:developer';
import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/services/auth_services.dart';
import 'package:zubizubi/services/video_services.dart';
import 'package:zubizubi/utils/toast.dart';
import '../app/app.locator.dart';

class ShellBottomNavigationBar extends StatefulWidget {
  const ShellBottomNavigationBar({super.key, required this.beamerKey});

  final GlobalKey<BeamerState> beamerKey;

  @override
  State<ShellBottomNavigationBar> createState() => _ShellBottomNavigationBarState();
}

class _ShellBottomNavigationBarState extends State<ShellBottomNavigationBar> {
  late BeamerDelegate _beamerDelegate;
  int currentIndex = 0;

  void _setStateListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    _beamerDelegate = widget.beamerKey.currentState!.routerDelegate;
    _beamerDelegate.addListener(_setStateListener);
  }

  final _authServices = locator<AuthServices>();

  uploadVideo() async {
    final videoPicker = ImagePicker();
    final pickedFile = await videoPicker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      await locator<VideoServices>().addVideo(context, File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
      backgroundColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex, // Set the current index
      onTap: (index) {
        if (currentIndex == index) {
          return;
        }
        currentIndex = index; // Update the current index
        switch (index) {
          case 0:
            log(index.toString());
            _beamerDelegate.beamToNamed('/home');
            break;
          case 1:
            log(index.toString());
            _beamerDelegate.beamToNamed('/search');
            break;
          case 2:
            log(index.toString());
            if (_authServices.isSignedIn()) {
              uploadVideo();
            } else {
              showToast("You need to be logged In to do that!");
              _beamerDelegate.beamToNamed('/login');
              return;
            }
            break;
          case 3:
            log(index.toString());
            _beamerDelegate.beamToNamed('/chats');
            break;
          case 4:
            log(index.toString());
            _beamerDelegate.beamToNamed('/profile');
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
            FontAwesomeIcons.circlePlus,
            color: Colors.white,
            size: 21,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(
            FontAwesomeIcons.facebookMessenger,
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
}
