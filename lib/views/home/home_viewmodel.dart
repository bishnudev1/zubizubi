import 'dart:developer';
import 'package:appwrite/models.dart' as UserModel;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/data/models/user.dart';
import '../../data/models/video.dart';
import '../../services/auth_services.dart';
import '../../services/video_services.dart';

class HomeViewModel extends BaseViewModel {
  final _authServices = locator<AuthServices>();
  User? _user;

  User? get user => _user;

  getUser() async {
    var userBox = Hive.box<User>('userBox');

    _user = userBox.getAt(0);
    notifyListeners();
  }

  logoutAccount(BuildContext context) async {
    await _authServices.logoutUser(context);
  }

  List<Video> videoList = [];

  final _videoServices = locator<VideoServices>();

  int currentIndex = 0;
  int prevVideo = 0;

  bool loading = false;

  init() async {
    await loadFetchNextBatchOfVideos();
    loadVideo(0);
    loadVideoInAdvance(1);
  }

  changeVideo(index) async {
    if (videoList![prevVideo].controller != null) {
      videoList![prevVideo].controller!.pause();

      if (videoList![prevVideo].controller!.value.isInitialized) {
        videoList![prevVideo].controller!.seekTo(Duration.zero);
      }

      if (index > prevVideo &&
          prevVideo - 1 >= 0 &&
          videoList![prevVideo - 1].controller != null &&
          videoList![prevVideo - 1].controller!.value.isInitialized) {
        log("disposing video index: ${prevVideo - 1}");
        videoList![prevVideo - 1].dispose();
      }

      if (index < prevVideo &&
          prevVideo + 1 < videoList!.length &&
          videoList![prevVideo + 1].controller != null &&
          videoList![prevVideo + 1].controller!.value.isInitialized) {
        log("disposing video index: ${prevVideo + 1}");
        videoList![prevVideo + 1].dispose();
      }
    }

    if (videoList![index].controller == null) {
      await videoList![index].loadController();
    }
    videoList![index].controller!.play();

    //  next video in advance
    if (index + 1 < videoList!.length) {
      log("loading video in advance for ${index + 1}");
      loadVideoInAdvance(index + 1);
    }
    if (index - 1 >= 0) {
      log("loading video in advance for ${index - 1}");
      loadVideoInAdvance(index - 1);
    }

    prevVideo = index;

    // fetch next batch of videos
    if (videoList!.length - 2 >= 0 &&
        index >= videoList!.length - 2 &&
        !loading) {
      loadFetchNextBatchOfVideos();
    }

    notifyListeners();

    log("Current index $index");
  }

  Future<void> loadFetchNextBatchOfVideos() async {
    if (loading) return;
    loading = true;
    notifyListeners();

    var newVideos = await _videoServices.fetchVideosInBatches();
    if (newVideos.length > 0) {
      log("All Videos: ${newVideos}");
      final allNewVideos = newVideos
          .map((e) => Video(
                  id: e['id'],
                  name: e['name'],
                  description: e['description'],
                  likes: e['likes'],
                  hideVideo: e['hideVideo'],
                  videoUrl: e['videoUrl'],
                  created: e['created'],
                  creator: e['creator'],
                  creatorName: e['creatorName'],
                  creatorUrl: e['creatorUrl']))
          .toList();
      videoList.addAll(allNewVideos.cast<Video>());
      notifyListeners();
    }

    loading = false;
    notifyListeners();
  }

  void loadVideo(int index) async {
    if (videoList!.length > index) {
      await videoList![index].loadController();
      videoList![index].controller?.play();
    }
    notifyListeners();
  }

  void loadVideoInAdvance(int index) async {
    if (videoList!.length > index && videoList![index].controller == null) {
      await videoList![index].loadController();
    }
    notifyListeners();
  }

  parseShareUrl(String url) {
    log("parseShareUrl called with $url");
    videoList = [];
    videoList.add(Video(
        id: "1",
        name: "Zubi-Zubi",
        description: "Zubi-Zubi Video",
        likes: 0,
        hideVideo: false,
        creator: "Zubi-Zubi",
        videoUrl: url,
        created: (DateTime.now().millisecondsSinceEpoch).toString(),
        creatorName: "Zubi-Zubi",
        creatorUrl: ""));
    loadVideo(0);
    notifyListeners();
  }

  addLike(String documentId) async {
    log("addLike called with $documentId");
    try {
      await _videoServices.addLike(documentId);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }

  saveDownloadVideo(String documentId) async {
    log("saveDownloadVideo called with $documentId");
    try {
      await _videoServices.downloadVideo(documentId);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }
}
