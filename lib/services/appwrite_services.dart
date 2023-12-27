import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:stacked/stacked.dart';

class AppwriteServices with ListenableServiceMixin {
  Client? _client;

  Future<void> init() async {
    _client = Client()
        .setEndpoint('https://appwrite.bishnudevs.in/v1')
        .setProject('658bf6d7d729c67607f5')
        .setSelfSigned(status: true);

    if(_client != null) {
      log("Appwrite Client Initialized");
      notifyListeners();
    }
    else{
      log("Appwrite Client Initialization Failed");
    }
  }
}
