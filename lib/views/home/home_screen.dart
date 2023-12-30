import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:zubizubi/utils/bottom_bar.dart';

import '../../data/models/video.dart';
import '../../utils/appbar/appbar.dart';
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
        await viewModel.init();

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
            // appBar: PreferredSize(
            //     preferredSize: Size.fromHeight(50), child: CustomAppBar()),
            body: SizedBox.expand(child: feedVideos(viewModel)),
            bottomNavigationBar: bottomNavigationBar(context),
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
      return videoCard(viewModel.videoList![index], viewModel, context);
    },
  );
}

Widget videoCard(Video video, HomeViewModel viewmodel, BuildContext context) {
  // log("videoCard CreatedBy: ${video.createdBy["createdBy"]![0]["photoUrl"]}");
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
        right: 20,
        bottom: 10,
        child: InkWell(
          onTap: () {
            Beamer.of(context).beamToNamed("/profile");
          },
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(video.creatorUrl),
          ),
        ),
      ),
      Positioned(
        right: 15,
        bottom: 65,
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                viewmodel.saveDownloadVideo(video.id);
              },
              icon: const FaIcon(
                FontAwesomeIcons.download,
                color: Colors.white,
                size: 30,
              ),
            ),
            Text(
              "Save",
              style: TextStyle(
                  fontFamily: "Canela",
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      Positioned(
        right: 15,
        bottom: 140,
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                Share.share("${video.videoUrl}",
                    subject: 'Check out this video!');
              },
              icon: const FaIcon(
                FontAwesomeIcons.share,
                color: Colors.white,
                size: 30,
              ),
            ),
            Text(
              "Share",
              style: TextStyle(
                  fontFamily: "Canela",
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      Positioned(
        right: 15,
        bottom: 200,
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                viewmodel.addLike(video.id);
              },
              icon: const FaIcon(
                FontAwesomeIcons.heart,
                color: Colors.white,
                size: 30,
              ),
            ),
            Text(
              "${video.likes}",
              style: TextStyle(
                  fontFamily: "Canela",
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      Positioned(
        right: 15,
        bottom: 270,
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                // Share.share("https://j-aan.com/admin/share?url=${video.url}", subject: 'Check out this video!');
              },
              icon: const FaIcon(
                FontAwesomeIcons.comment,
                color: Colors.white,
                size: 30,
              ),
            ),
            Text(
              "${0}",
              style: TextStyle(
                  fontFamily: "Canela",
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      Positioned(
        left: 15,
        bottom: 70,
        child: Text(
          video.creatorName,
          style: GoogleFonts.zillaSlab(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      Positioned(
        left: 15,
        bottom: 40,
        child: Text(
          "${video.description} 👻",
          style: GoogleFonts.zillaSlab(
              fontSize: 15, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
