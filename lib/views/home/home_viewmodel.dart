import 'dart:convert';
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
import 'package:collection/collection.dart';

class HomeViewModel extends BaseViewModel {
  final _authServices = locator<AuthServices>();
  User? _user;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User? get user => _user;

  TextEditingController commentController = TextEditingController();

  getUser() async {
    var userBox = Hive.box<User>('userBox');

    _user = userBox.getAt(0);

    notifyListeners();
  }

  checkIsVideoLikedByUser(Video video) async {
    final resp = await _authServices.getUser();

    final userMap = User.fromMap(resp);

    String videoLikesMap = video.likes[0];

    Map<String, dynamic> userMapForComparison = {
      "name": userMap.name,
      "email": userMap.email,
      "photoUrl": userMap.photoUrl,
      "id": userMap.id,
      "createdAt": userMap.createdAt,
      "followers": userMap.followers,
      "shares": userMap.shares
    };
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
    if (videoList[prevVideo].controller != null) {
      videoList[prevVideo].controller!.pause();

      if (videoList[prevVideo].controller!.value.isInitialized) {
        videoList[prevVideo].controller!.seekTo(Duration.zero);
      }

      if (index > prevVideo &&
          prevVideo - 1 >= 0 &&
          videoList[prevVideo - 1].controller != null &&
          videoList[prevVideo - 1].controller!.value.isInitialized) {
        log("disposing video index: ${prevVideo - 1}");
        videoList[prevVideo - 1].dispose();
      }

      if (index < prevVideo &&
          prevVideo + 1 < videoList.length &&
          videoList[prevVideo + 1].controller != null &&
          videoList[prevVideo + 1].controller!.value.isInitialized) {
        log("disposing video index: ${prevVideo + 1}");
        videoList[prevVideo + 1].dispose();
      }
    }

    if (videoList[index].controller == null) {
      await videoList[index].loadController();
    }
    videoList[index].controller!.play();

    //  next video in advance
    if (index + 1 < videoList.length) {
      log("loading video in advance for ${index + 1}");
      loadVideoInAdvance(index + 1);
    }
    if (index - 1 >= 0) {
      log("loading video in advance for ${index - 1}");
      loadVideoInAdvance(index - 1);
    }

    prevVideo = index;

    // fetch next batch of videos
    if (videoList.length - 2 >= 0 &&
        index >= videoList.length - 2 &&
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
      log("All Videos: $newVideos");
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
              comments: e['comments'],
              creatorUrl: e['creatorUrl']))
          .toList();
      videoList.addAll(allNewVideos.cast<Video>());
      notifyListeners();
    }

    loading = false;
    notifyListeners();
  }

  void loadVideo(int index) async {
    if (videoList.length > index) {
      await videoList[index].loadController();
      videoList[index].controller?.play();
    }
    notifyListeners();
  }

  void loadVideoInAdvance(int index) async {
    if (videoList.length > index && videoList[index].controller == null) {
      await videoList[index].loadController();
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
        likes: [],
        hideVideo: false,
        creator: "Zubi-Zubi",
        videoUrl: url,
        comments: [],
        created: (DateTime.now().millisecondsSinceEpoch).toString(),
        creatorName: "Zubi-Zubi",
        creatorUrl: ""));
    loadVideo(0);
    notifyListeners();
  }

  addLike(String documentId, int index) async {
    log("addLike called with $documentId");
    log("${_user!.toMap()}");
    // final videoBox = Hive.box<Video>('videoBox');
    try {
      // videoBox.get(documentId)?.likes.add(_user!.toMap().toString());
      // videoList[currentIndex].likes.add(_user!.toMap().toString());
      // notifyListeners();
      await _videoServices.addLike(
          documentId, _user!.email, videoList[index].likes);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }

  removeLike(String documentId, int index) async {
    log("removeLike called with $documentId");
    log("${_user!.toMap()}");
    try {
      await _videoServices.removeLike(
          documentId, _user!.email, videoList[index].likes);
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

  addComment(BuildContext context,List comment, String index) async {
    log("addComment called with $comment");
    try {
      await _videoServices.videoComment(context,comment, index, _user!, commentController.text.trim().toString());
      notifyListeners();
      commentController.clear();
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }

  deleteComment(BuildContext context,List comment, String id, dynamic commentData) async {
    log("deleteComment called with $comment");
    try {
      await _videoServices.deleteMyComment(context,comment, id, commentData);
      notifyListeners();
    } catch (e) {
      log("Error: $e");
    }
  }
}
