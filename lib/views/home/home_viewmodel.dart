

import 'dart:developer';

import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import '../../data/models/video.dart';
import '../../services/auth_services.dart';
import '../../services/video_services.dart';

class HomeViewModel extends BaseViewModel{
  final _authServices = locator<AuthServices>();

  loginWithFacebook() async {
    await _authServices.handleFacebookLogin();
  }

  loginWithGoogle() async {
    await _authServices.handleGoogleLogin();
  }
    List<Video>? videoList;

  final _videoServices = locator<VideoServices>();

  int currentIndex = 0;
  int prevVideo = 0;

  bool loading = false;

  init() async{
    await loadFetchNextBatchOfVideos();
    // var initialVideoList = _videoServices
    //     .demoVideoUrls()
    //     .map<Video>((e) => Video(url: e, id: "123", likes: 32, videoTitle: "test"))
    //     .toList();

    // var random  = math.Random();

    // initialVideoList.shuffle(random);

    // if (videoList == null) {
    //   videoList = initialVideoList;
    // } else {
    //   videoList!.addAll(initialVideoList);
    // }
    // loadFetchNextBatchOfVideos();

    // auto play first video
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

    videoList ??= [];

    var newVideos = await _videoServices.fetchVideosInBatches();
    if (newVideos.length > 0) {
      var newVideoList = newVideos
          .map<Video>(
              (e) => Video(url: e, id: "123", likes: 32, videoTitle: "test"))
          .toList();
      videoList!.addAll(newVideoList);
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
    videoList!.add(Video(url: url, id: "123", likes: 32, videoTitle: "shared"));
    loadVideo(0);
    notifyListeners();
  }
}