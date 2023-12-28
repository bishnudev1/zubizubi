import 'dart:developer';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/utils/toast.dart';

class AuthServices with ListenableServiceMixin {
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
      final res = await account.createOAuth2Session(
        provider: 'facebook',
      );
      log('Facebook Login Response: $res');
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

      final res = await account.createOAuth2Session(provider: 'google');
      log('Google Login Response: $res');
    } on PlatformException catch (e) {
      showToast(e.message.toString());
      log('PlatformException: $e');
    } on AppwriteException catch (e) {
      showToast(e.message.toString());
      log('AppwriteException: $e');
    } catch (e) {
      log(e.toString());
    }
  }
}
