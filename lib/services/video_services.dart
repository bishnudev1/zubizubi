import 'dart:developer';
import 'dart:io' as IO;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/appwrite_services.dart';
import 'package:zubizubi/services/auth_services.dart';
import 'package:zubizubi/utils/toast.dart';

import '../data/models/user.dart' as UserModel;
import '../data/models/video.dart' as VideoModel;

class VideoServices with ListenableServiceMixin {
  final _appwriteServices = locator<AppwriteServices>();
  final _authServices = locator<AuthServices>();

  addVideo(BuildContext context, IO.File image) async {
    try {
      final user = Hive.box<UserModel.User>('userBox').getAt(0);
      final email = user?.email;
      if (context.mounted) {
        await _appwriteServices.addNewVideo(email!, image);
      }
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

  fetchVideosInBatches() async {
    List<Document> videoSnapshot = await _appwriteServices.getVideos();

    // log("videosSnapshot length @videoServices: ${videoSnapshot.length}");

    var videos = videoSnapshot.map((e) {
      var data = e.data;
      return data;
    }).toList();

    // log("videos @videoServices: $videos");

    return videos;
  }

  fetchUserVideos(String email) async {
    List<Document> videoSnapshot = await _authServices.getUserVideos(email);

    // log("videosSnapshot length @videoServices: ${videoSnapshot.length}");

    var videos = videoSnapshot.map((e) {
      var data = e.data;
      return data;
    }).toList();

    // log("videos @videoServices: $videos");

    return videos;
  }

  addLike(String documentId, String email, List videoList) async {
    try {
      await _appwriteServices.likeVideo(documentId, email, videoList);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }

  removeLike(String documentId, String email, List videoList) async {
    try {
      await _appwriteServices.dislikeVideo(documentId, email, videoList);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }

  downloadVideo(String documentId) async {
    try {
      await _appwriteServices.saveVideo(documentId);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }

    videoComment(BuildContext context,List comments, String id, UserModel.User user, String comment) async {
    try {
      await _appwriteServices.addNewComment(context,comments, id, user, comment);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }
}
