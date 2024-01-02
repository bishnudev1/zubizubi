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
  List<String> followersList = [];
  User? _user;

  User? get user => _user;
getFollowers() async {
  try {
    final resp = _user?.followers ?? [];
    final followers = jsonEncode(resp);
    
    log("Followers: ${resp}");
    
    log("Followers List 1: ${followersList}");
    
    // Split the string and add individual elements to followersList
    followers.toString().split(",").forEach((element) {
      followersList.add(element.replaceAll('"', '').trim());
    });
    
    log("Followers List after adding: ${followersList}");
    
    log("First element of Followers List 2: ${followersList[0].length}");
    
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
