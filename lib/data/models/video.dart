import 'dart:developer';
import 'package:video_player/video_player.dart';

class Video {
  String id;
  String name;
  String description;
  int likes;
  bool hideVideo;
  String videoUrl;
  String creator;
  String creatorName;
  String created;
  String creatorUrl;

  VideoPlayerController? controller;

  Video({
    required this.id,
    required this.name,
    required this.description,
    required this.likes,
    required this.hideVideo,
    required this.videoUrl,
    required this.created,
    required this.creator,
    required this.creatorUrl,
    required this.creatorName,
  });

  Video.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'], // Use 'videoTitle' directly
        description = json["description"],
        likes = json['likes'],
        hideVideo = json["hideVideo"],
        videoUrl = json['videoUrl'],
        creator = json['creator'],
        created = json['created'],
        creatorName = json['creatorName'],
        creatorUrl = json['creatorUrl'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data["description"] = description;
    data['likes'] = likes;
    data["hideVideo"] = hideVideo;
    data['videoUrl'] = videoUrl;
    data["created"] = created;
    data['creator'] = creator;
    data['creatorUrl'] = creatorUrl;
    data['creatorName'] = creatorName;
    return data;
  }

  Future<void> loadController() async {
    log("loadController called for $videoUrl");
    // var file = await videoCacheManger.getSingleFile(url);
    var uri = Uri.parse(videoUrl);
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
      id: "id",
      name: map['name'], // Use 'videoTitle' directly
      description: map["description"],
      likes: map['likes'],
      hideVideo: map['hideVideo'],
      videoUrl: map['videoUrl'],
      creator: map['creator'],
      created: map["created"],
      creatorUrl: map['creatorUrl'],
      creatorName: map['creatorName'],
    );
  }
}
