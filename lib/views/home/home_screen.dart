import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/video.dart';
import 'home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  final String? shareUrl;
  const HomeScreen({Key? key, this.shareUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomeViewModel(),
      createNewViewModelOnInsert: true,
      onViewModelReady: (viewModel) async {
        // await viewModel.initVideoPlayer();
        log("shareUrl: $shareUrl");
        if (shareUrl != null) {
          log("shareUrl: $shareUrl");
          await viewModel.parseShareUrl(shareUrl!);
        }
        // await viewModel.init();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.getUser();
        });
      },
      builder: (context, viewModel, child) {
        if (viewModel.isBusy) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (viewModel.hasError) {
          return Scaffold(
            body: Center(
              child: Text(viewModel.error.toString()),
            ),
          );
        }
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            // body: SizedBox.expand(child: feedVideos(viewModel)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Welcome ${viewModel.user?.name ?? ""}"),
                  Text("Email: ${viewModel.user?.email ?? ""}"),
                  ElevatedButton(
                      onPressed: () => viewModel.logoutAccount(),
                      child: const Text("Logout")),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget feedVideos(HomeViewModel viewModel) {
  return PageView.builder(
    controller: PageController(
      initialPage: 0,
      viewportFraction: 1,
    ),
    itemCount: viewModel.videoList!.length,
    onPageChanged: (index) {
      index = index % (viewModel.videoList!.length);
      viewModel.changeVideo(index);
    },
    scrollDirection: Axis.vertical,
    itemBuilder: (context, index) {
      index = index % (viewModel.videoList!.length);
      return videoCard(viewModel.videoList![index], context);
    },
  );
}

Widget videoCard(Video video, BuildContext context) {
  return Stack(
    children: [
      video.controller != null
          ? GestureDetector(
              onTap: () {
                if (video.controller!.value.isPlaying) {
                  video.controller?.pause();
                } else {
                  video.controller?.play();
                }
              },
              child: SizedBox.expand(
                  child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: video.controller?.value.size.width ?? 0,
                  height: video.controller?.value.size.height ?? 0,
                  child: VideoPlayer(video.controller!),
                ),
              )),
            )
          : Container(
              color: Colors.black,
            ).animate(
              onPlay: (controller) {
                controller.repeat();
              },
            ).shimmer(
              duration: const Duration(seconds: 2),
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              curve: Curves.ease,
            ),
      Positioned(
        right: 15,
        bottom: 15,
        child: IconButton(
          onPressed: () {
            // Share.share("https://j-aan.com/admin/share?url=${video.url}", subject: 'Check out this video!');
          },
          icon: const FaIcon(
            FontAwesomeIcons.share,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    ],
  );
}
