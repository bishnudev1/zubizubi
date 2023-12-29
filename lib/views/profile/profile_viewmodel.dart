import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/auth_services.dart';
import 'package:appwrite/models.dart' as UserModel;
import 'package:zubizubi/utils/alertbox.dart';

import '../../data/models/user.dart';

class ProfileViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  User? _user;

  User? get user => _user;

  getUser() async {
    UserModel.User user = await _authServices.getCurrentUser();
    _user = User(
      id: user.$id,
      name: user.name,
      email: user.email,
      photoUrl: "",
      likes: 0,
      shares: 0,
      // photoUrl: user.photoUrl,
      createdAt: user.registration,
    );
    notifyListeners();
  }

  logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertBox(
            alertText: "Are you sure want to logout ?",
            onYesPressed: () async {
              _authServices.logoutUser();
            });
      },
    );
  }
}
