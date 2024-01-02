import 'dart:developer';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/services/auth_services.dart';
import 'package:appwrite/models.dart' as UserModel;
import 'package:zubizubi/services/video_services.dart';
import 'package:zubizubi/utils/alertbox.dart';
import 'package:zubizubi/utils/toast.dart';

import '../../data/models/user.dart';
import '../../data/models/video.dart';

class ProfileViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  final _videoServices = locator<VideoServices>();
  User? _user;
  final imagePicker = ImagePicker();

  TextEditingController bioController = TextEditingController();

  List<Video> userVideos = [];

  User? get user => _user;
  bool isLoading = false;

  getUserVideos(String creator) async {
    try {
      final videos = await _videoServices.fetchUserVideos(creator);
      log("Videos of Current User Length: ${videos.length}");
      if (videos.length > 0) {
        final allUserVideos = videos
            .map((e) => Video(
                  id: e['id'],
                  name: e['name'],
                  description: e['description'],
                  likes: e['likes'],
                  hideVideo: e['hideVideo'],
                  videoUrl: e['videoUrl'],
                  created: e['created'],
                  creator: e['creator'],
                  creatorName: e['creatorName'],
                  creatorUrl: e['creatorUrl'],
                  comments: e['comments'],
                ))
            .toList();
        userVideos.addAll(allUserVideos.cast<Video>());
        log("userVideos: ${userVideos}");
        notifyListeners();
      }
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }

  goToFollowersScreen() {
    routerDelegate.beamToNamed('/followers');
  }

  getUser() async {
    var userBox = Hive.box<User>('userBox');

    log("User Box Length: ${userBox.length}");

    _user = userBox.getAt(0);
    notifyListeners();
  }

  Future<void> changeImage(BuildContext context) async {
    log("User id: ${_user?.id}");
    if (isLoading) {
      return;
    }
    isLoading = true;
    notifyListeners();
    showDialog(
      context: context,
      builder: (context) {
        return AlertBox(
            showCancel: true,
            alertText: "Delete profile photo or update it ?",
            firstText: "Update",
            secondText: "Delete",
            thirdPressed: () {
              isLoading = false;
              notifyListeners();
              Navigator.pop(context);
            },
            onSecondPressed: () {
              try {
                _authServices.deleteProfileImage(context);
                notifyListeners();
                getUser();
                notifyListeners();
              } on PlatformException catch (e) {
                log(e.toString());
              } on AppwriteException catch (e) {
                log(e.toString());
              } catch (e) {
                log(e.toString());
              }
              isLoading = false;
              notifyListeners();
            },
            onFirstPressed: () async {
              try {
                log("User: $_user");
                final pickedFile =
                    await imagePicker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  await _authServices.updateProfileImage(
                      context,
                      File(
                        pickedFile.path,
                      ),
                      _user?.id ?? "");
                  notifyListeners();
                  getUser();
                  notifyListeners();
                }
              } on PlatformException catch (e) {
                log(e.toString());
              } on AppwriteException catch (e) {
                log(e.toString());
              } catch (e) {
                log(e.toString());
              }
              isLoading = false;
              notifyListeners();
            });
      },
    );
  }

  logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertBox(
            firstText: "Yes",
            secondText: "No",
            onSecondPressed: () {
              Navigator.pop(context);
            },
            alertText: "Are you sure want to logout ?",
            onFirstPressed: () async {
              _authServices.logoutUser(context);
            });
      },
    );
  }

  editBio(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text("Edit Bio"),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: bioController,
              decoration: InputDecoration(
                hintText: user?.bio ?? "Add Bio",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.aDLaMDisplay(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (bioController.text.isNotEmpty) {
                    await _authServices.editProfileBio(
                        bioController.text, user!.id);
                    getUser();
                    notifyListeners();
                    Navigator.pop(context);
                  } else {
                    showToast("Bio cannot be empty");
                  }
                } on PlatformException catch (e) {
                  log(e.toString());
                } on AppwriteException catch (e) {
                  log(e.toString());
                } catch (e) {
                  log(e.toString());
                } finally {
                  // Navigator.pop(context);
                }
              },
              child: Text(
                "Save",
                style: GoogleFonts.aDLaMDisplay(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
