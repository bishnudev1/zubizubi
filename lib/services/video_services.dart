import 'dart:developer';

import 'package:appwrite/models.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/appwrite_services.dart';

class VideoServices with ListenableServiceMixin {
  final _appwriteServices = locator<AppwriteServices>();

  fetchVideosInBatches() async {
    List<Document> videoSnapshot = await _appwriteServices.getVideos();

    log("videosSnapshot length @videoServices: ${videoSnapshot.length}");

    var videos = videoSnapshot.map<String>((e) {
      var data = e.data;
      return data['videoUrl'];
    }).toList();

    log("videos @videoServices: $videos");

    return videos;
  }
}