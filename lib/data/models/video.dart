import 'dart:developer';
import 'package:video_player/video_player.dart';

class Video {
  String id;
  String videoTitle;
  int likes;
  String url;

  VideoPlayerController? controller;

  Video({required this.id, required this.videoTitle, required this.likes, required this.url});

  Video.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        videoTitle = json['video_title'],
        likes = json['likes'],
        url = json['url'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['video_title'] = videoTitle;
    data['likes'] = likes;
    data['url'] = url;
    return data;
  }

  Future<void> loadController() async {
    log("loadController called for $url");
    // var file = await videoCacheManger.getSingleFile(url);
    var uri = Uri.parse(url);
    controller = VideoPlayerController.networkUrl(uri);
    await controller?.initialize();
    controller?.setVolume(0);
    controller?.setLooping(true);
  }

  void dispose() {
    controller?.dispose();
    controller = null;
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: "1",
      videoTitle: map['description'],
      likes: map['likes'],
      url: map['videoUrl'],
    );
  }
}
