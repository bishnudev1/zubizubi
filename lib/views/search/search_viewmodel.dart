import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/data/models/user.dart';
import 'package:zubizubi/services/auth_services.dart';

class SearchViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  List<User> userList = [];

  List<User> searchList = [];

  TextEditingController searchController = TextEditingController();


  getAllUsers() async {
    try {
      final usersResp = await _authServices.getAllUsers();
      var usersData = usersResp.map((e) {
        var data = e.data;
        return data;
      }).toList();
      if (usersData.length > 0) {
        final users = usersData
            .map((e) => User(
                    id: e['id'],
                    name: e['name'],
                    email: e['email'],
                    followers: e['followers'],
                    shares: e['shares'],
                    createdAt: e['createdAt'],
                    photoUrl: e['photoUrl'],))
            .toList();
        userList.addAll(users.cast<User>());
        notifyListeners();
      }
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  searchUsers() async {
    try {
      final searchUserList = userList
          .where((element) => element.name!
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
      searchList = searchUserList;
      notifyListeners();
      log("searchList: ${searchList.length}");
    } catch (e) {
      log("error: $e");
    }
  }
}
