import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:stacked/stacked.dart';

class AppwriteServices with ListenableServiceMixin {
  Client? _client;
   String? lastId;

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

  Future<List<Document>> getVideos() async { 
    if (_client == null) {
      log("Appwrite client got null");
      null;
    }
    final databases = Databases(_client!);

    try {
      final documents = await databases.listDocuments(
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ebf9654ca69759383',
        queries: [
          Query.limit(1000),
          Query.orderDesc("created"),
          if (lastId != null) Query.cursorAfter(lastId!),
        ],
      );

      log("Appwrite documents: $documents");

      final data = documents.documents;

      log("Appwrite video data length: ${data.length}");

      if (data.isNotEmpty) {
        lastId = data.last.$id;
      } else {
        lastId = null;
      }

      data.shuffle();

      return data;
    } on AppwriteException catch (e) {
      log("AppwriteException: $e");
      return [];
    }
  }
}
