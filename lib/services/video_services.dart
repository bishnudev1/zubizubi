import 'dart:developer';
import 'dart:io' as IO;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/appwrite_services.dart';
import 'package:zubizubi/services/auth_services.dart';
import 'package:zubizubi/utils/toast.dart';

class VideoServices with ListenableServiceMixin {
  final _appwriteServices = locator<AppwriteServices>();
  final _authServices = locator<AuthServices>();

  addVideo(BuildContext context, IO.File image) async {
    try {
      final user = await _authServices.getCurrentUser();
      final email = user['email'];
      await _appwriteServices.addNewVideo(context, email, image);
      notifyListeners();
      fetchUserVideos(email);
      fetchVideosInBatches();
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

  addLike(String documentId) async {
    try {
      await _appwriteServices.likeVideo(documentId);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }

  downloadVideo(String documentId)async{
    try {
      await _appwriteServices.saveVideo(documentId);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }
}
