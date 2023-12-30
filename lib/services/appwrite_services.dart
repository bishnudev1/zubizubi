import 'dart:developer';
import 'dart:io' as IO;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/utils/toast.dart';

class AppwriteServices with ListenableServiceMixin {
  Client? _client;
  String? lastId;

  Future<void> init() async {
    _client = Client()
        .setEndpoint('https://appwrite.bishnudevs.in/v1')
        .setProject('658bf6d7d729c67607f5')
        .setSelfSigned(status: true);

    if (_client != null) {
      log("Appwrite Client Initialized");
      notifyListeners();
    } else {
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

  addNewVideo(String email, IO.File file) async {
    if (_client == null) {
      log("Appwrite client got null");
      null;
    }
    final storage = Storage(_client!);
    final databases = Databases(_client!);
    try {
      final videoId = DateTime.now().millisecondsSinceEpoch.toString();
      await storage.createFile(
        bucketId: "658ec05b5ecf34a1cea7",
        fileId: videoId,
        file: InputFile.fromPath(path: file.path),
      );

      final videoUrl =
          "https://appwrite.bishnudevs.in/v1/storage/buckets/658ec05b5ecf34a1cea7/files/$videoId/view?project=658bf6d7d729c67607f5";

      String fileName = IO.File(file.path).uri.pathSegments.last;

      final resp = await databases.listDocuments(
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ec36c61220704a694',
        queries: [Query.equal("email", email)],
      );

      Map<String, dynamic> getauthor = resp.documents[0].data;

      log("getauthor: $getauthor");

      await databases.createDocument(
        documentId: videoId,
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ebf9654ca69759383',
        data: {
          "id": videoId,
          "name": fileName,
          "likes": 0,
          "description": "Zubi-Zubi Video",
          "hideVideo": false,
          "creator": email,
          "videoUrl": videoUrl,
          "created": (DateTime.now().millisecondsSinceEpoch).toString(),
          "creatorUrl": getauthor['photoUrl'],
          "creatorName": getauthor['name'],
        },
      );

      notifyListeners();
      showToast("Video Uploaded Successfully");
      routerDelegate.beamToNamed('/shell');
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

  likeVideo(String documentId) async {
    if (_client == null) {
      log("Appwrite client got null");
      null;
    }
    final databases = Databases(_client!);

    try {
      final getDocument = await databases.getDocument(
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ebf9654ca69759383',
        documentId: documentId,
      );

      final likes = getDocument.data['likes'];

      final newLikes = likes + 1;

      await databases.updateDocument(
          documentId: documentId,
          databaseId: '658ebf7877a5df4a9f60',
          collectionId: '658ebf9654ca69759383',
          data: {
            "likes": newLikes,
          });
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
  }

  saveVideo(String documentId) async {
    if (_client == null) {
      log("Appwrite client got null");
      null;
    }
    final storage = Storage(_client!);

    try {
      await storage.getFileDownload(bucketId: "658ec05b5ecf34a1cea7", fileId: documentId);
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
