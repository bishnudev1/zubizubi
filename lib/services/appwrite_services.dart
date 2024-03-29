import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io' as IO;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/utils/toast.dart';

import '../data/models/user.dart' as UserModel;

class CachedData {
  List<Document>? videoList;
  DateTime? timeAdded;

  CachedData({this.videoList, this.timeAdded});
}

class AppwriteServices with ListenableServiceMixin {
  Client? _client;

  CachedData? cachedData;

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

  Future<List<Document>> getVideos({required String? offsetId}) async {
    try {
      log("Appwrite cachedData $cachedData ${cachedData?.timeAdded} ${cachedData?.videoList}");
      var timeNow = DateTime.now();
      if (cachedData?.videoList != null &&
          cachedData?.timeAdded != null &&
          cachedData!.videoList!.isNotEmpty &&
          cachedData!.videoList!.last.$id != offsetId &&
          timeNow.difference(cachedData!.timeAdded!).inMinutes < 2) {
        log("sending cached data");
        return cachedData!.videoList!;
      }

      if (_client == null) {
        log("Appwrite client got null");
      }
      final databases = Databases(_client!);

      final documents = await databases.listDocuments(
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ebf9654ca69759383',
        queries: [
          Query.limit(500),
          Query.orderDesc("created"),
          if (offsetId != null) Query.cursorAfter(offsetId),
        ],
      );

      log("Appwrite documents: $documents");

      final data = documents.documents;

      log("Appwrite video data length: ${data.length}");

      data.shuffle();

      cachedData = CachedData(videoList: data, timeAdded: DateTime.now());

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
          "likes": [],
          "description": "Zubi-Zubi Video",
          "hideVideo": false,
          "creator": email,
          "videoUrl": videoUrl,
          "created": (DateTime.now().millisecondsSinceEpoch).toString(),
          "creatorUrl": getauthor['photoUrl'],
          "creatorName": getauthor['name'],
          "comments": [],
        },
      );

      notifyListeners();
      showToast("Video Uploaded Successfully");
      routerDelegate.beamToNamed('/home');
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

  likeVideo(String documentId, String email, List videoList) async {
    log("likedUser: $email");
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
      log("likes: $likes");

      if (likes.contains(email.toString())) {
        log("returning");
        return;
      }

      videoList.add(email.toString());
      notifyListeners();

      likes.add(email.toString());

      await databases.updateDocument(
          documentId: documentId,
          databaseId: '658ebf7877a5df4a9f60',
          collectionId: '658ebf9654ca69759383',
          data: {
            "likes": likes,
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

  dislikeVideo(String documentId, String email, List videoList) async {
    log("disLikedUser: $email");
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
      log("likes: $likes");

      if (!likes.contains(email.toString())) {
        log("returning");
        return;
      }

      videoList.remove(email.toString());
      notifyListeners();

      likes.remove(email.toString());

      await databases.updateDocument(
          documentId: documentId,
          databaseId: '658ebf7877a5df4a9f60',
          collectionId: '658ebf9654ca69759383',
          data: {
            "likes": likes,
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

  deleteComment(BuildContext context, List comments, String id, dynamic comment) async {
    try {
      log("deleteComment: $id");
      if (_client == null) {
        log("Appwrite client got null");
        null;
      }
      final databases = Databases(_client!);
      final getDocument = await databases.getDocument(
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ebf9654ca69759383',
        documentId: id,
      );

      final getComments = getDocument.data['comments'];

      comments.removeWhere((element) => element == jsonEncode(comment));

      notifyListeners();

      getComments.removeWhere((element) => element == jsonEncode(comment));

      await databases.updateDocument(
          documentId: id,
          databaseId: '658ebf7877a5df4a9f60',
          collectionId: '658ebf9654ca69759383',
          data: {
            "comments": getComments,
          });

      // routerDelegate.popBeamLocation();
      notifyListeners();

      //
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

  addNewComment(BuildContext context, List comments, String id, UserModel.User user, String comment) async {
    try {
      log("addNewComment: $id");
      if (_client == null) {
        log("Appwrite client got null");
        null;
      }
      final databases = Databases(_client!);
      final getDocument = await databases.getDocument(
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ebf9654ca69759383',
        documentId: id,
      );

      final getComments = getDocument.data['comments'];

      // local save
      comments.add(jsonEncode({
        "data": {
          "comment": comment,
          "createdAt": DateFormat('dd-MM-yy').format(DateTime.now()).toString(),
        },
        "user": user.toMap(),
      }));
      notifyListeners();

      getComments.add(jsonEncode({
        "data": {
          "comment": comment,
          "createdAt": DateFormat('dd-MM-yy').format(DateTime.now()).toString(),
        },
        "user": user.toMap(),
      }));

      await databases.updateDocument(
          documentId: id,
          databaseId: '658ebf7877a5df4a9f60',
          collectionId: '658ebf9654ca69759383',
          data: {
            "comments": getComments,
          });
      notifyListeners();
      Navigator.pop(context);
      // showToast("Comment Added Successfully");
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

  searchAccountByEmail(String email) async {
    if (_client == null) {
      log("Appwrite client got null");
      null;
    }
    final databases = Databases(_client!);

    try {
      final resp = await databases.listDocuments(
        databaseId: '658ebf7877a5df4a9f60',
        collectionId: '658ec36c61220704a694',
        queries: [Query.equal("email", email)],
      );

      log("Appwrite documents: $resp");

      final data = resp.documents;

      log("Appwrite video data length: ${data.length}");

      if (data.isNotEmpty) {
        return data[0];
      } else {
        return null;
      }
    } on AppwriteException catch (e) {
      log("AppwriteException: $e");
      return null;
    }
  }
}
