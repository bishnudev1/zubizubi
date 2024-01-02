import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/data/models/user.dart';
import 'package:zubizubi/services/auth_services.dart';

class SearchViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  List<User> userList = [];

  List<User> searchList = [];

  User? _user;

  User? get user => _user;

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
                  photoUrl: e['photoUrl'],
                  bio: e['bio'],
                ))
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

  getUser() async {
    var userBox = Hive.box<User>('userBox');

    log("User Box Length: ${userBox.length}");

    _user = userBox.getAt(0);
    notifyListeners();
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

  followUser(String email, List followers, String id) async {
    log("followUser email : $email");

    try {
      await _authServices.followUser(email, followers, id);
      notifyListeners();
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  unfollowUser(String email, List followers, String id) async {
    try {
      await _authServices.unfollowUser(
        email,
        followers,
        id,
      );
      notifyListeners();
    } on PlatformException catch (e) {
      log(e.toString());
    } on AppwriteException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }
}
