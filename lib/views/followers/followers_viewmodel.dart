import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/appwrite_services.dart';
import 'package:zubizubi/services/auth_services.dart';

import '../../data/models/user.dart';

class FollowersViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  final _appwriteServices = locator<AppwriteServices>();
  List followersList = [];
  User? _user;

  User? get user => _user;
  getFollowers() async {
    try {
      final resp = _user?.followers ?? [];

      log("resp: ${resp[1]}");

      followersList = resp;

      log("followersList Type: ${followersList[1]}");

      // notifyListeners();
      // final account = await _appwriteServices.searchAccountByEmail(followersList[0].toString());
      // log(followersList.toString());
      // log("Account: ${account.data}");
    } catch (e) {
      log(e.toString());
    }
  }

  getUser() async {
    var userBox = Hive.box<User>('userBox');

    log("User Box Length: ${userBox.length}");

    _user = userBox.getAt(0);
    notifyListeners();
  }
}
