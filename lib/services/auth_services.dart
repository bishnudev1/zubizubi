import 'dart:developer';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/utils/toast.dart';

class AuthServices with ListenableServiceMixin {

  final _navigationService = locator<NavigationService>();

  Client client = Client()
      .setEndpoint('https://appwrite.bishnudevs.in/v1')
      .setProject('658bf6d7d729c67607f5')
      .setSelfSigned(status: true);

  handleFacebookLogin() async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      final account = Account(client);
      await account.createOAuth2Session(
        provider: 'facebook',
      );
      notifyListeners();
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    }
//     final LoginResult result = await FacebookAuth.instance
//         .login(); // by default we request the email and the public profile
// // or FacebookAuth.i.login()
//     if (result.status == LoginStatus.success) {
//       // you are logged
//       final AccessToken accessToken = result.accessToken!;
//       log(accessToken.toString());
//     } else {
//       log(result.status.toString());
//       log(result.message.toString());
//     }
  }

  handleGoogleLogin() async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      final account = Account(client);

      await account.createOAuth2Session(provider: 'google');
      showToast("Login Successful");
      notifyListeners();
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } catch (e) {
      log(e.toString());
    }finally{
      // _navigationService.replaceWith('/home');
    }
  }

  getCurrentUser() async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return null;
    }
    try {
      final account = Account(client);
      final res = await account.get();
      notifyListeners();
      log('Current User: ${res.toString()}');
      log("Current User Email: ${res.email}");
      return res;
    } on PlatformException catch (e) {
      return null;
    } on AppwriteException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  logoutUser() async {
    if (client == null) {
      showToast("Appwrite Client Initialization Failed");
      return;
    }
    try {
      final account = Account(client);
      account.deleteSession(sessionId: 'current');
      showToast("Logout Successful");
      notifyListeners();
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } catch (e) {
      log(e.toString());
    }
    finally{
      // _navigationService.replaceWith('/login');
    }
  }
}
