import 'dart:convert';
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
import 'package:zubizubi/utils/toast.dart';

import '../../app/routes.dart';
import '../../data/models/video.dart';
import 'home_viewmodel.dart';

class ShellScreen extends StatelessWidget {
  ShellScreen({Key? key}) : super(key: key);

  final _beamerKey = GlobalKey<BeamerState>();
  final _routerDelegate = BeamerDelegate(
    initialPath: '/home',
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        HomeLocation(),
        ProfileLocation(),
        SearchLocation(),
        FollowersLocation(),
        LoginLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Beamer(
        key: _beamerKey,
        routerDelegate: _routerDelegate,
      ),
      bottomNavigationBar: ShellBottomNavigationBar(
        beamerKey: _beamerKey,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String? shareUrl;
  const HomeScreen({super.key, this.shareUrl});

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
        return WillPopScope(
          onWillPop: () {
            if (viewModel.videoList[viewModel.currentIndex].controller != null) {
              viewModel.videoList[viewModel.currentIndex].controller?.pause();
            }
            log("");
            return Future.value(true);
          },
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              // appBar: PreferredSize(
              //     preferredSize: Size.fromHeight(50), child: CustomAppBar()),
              body: SizedBox.expand(child: feedVideos(viewModel)),
              // bottomNavigationBar: const ShellBottomNavigationBar(),
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
    itemCount: viewModel.videoList.length,
    onPageChanged: (index) {
      index = index % (viewModel.videoList.length);
      viewModel.changeVideo(index);
    },
    scrollDirection: Axis.vertical,
    itemBuilder: (context, index) {
      index = index % (viewModel.videoList.length);
      viewModel.currentIndex = index;
      return videoCard(viewModel.videoList[index], viewModel, context, index);
    },
  );
}

Widget videoCard(Video video, HomeViewModel viewmodel, BuildContext context, int index) {
  // viewmodel.checkIsVideoLikedByUser(video);

  final isLiked = video.likes.contains(viewmodel.user?.email.toString());

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
            radius: 16,
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
                size: 25,
              ),
            ),
            const Text(
              "Save",
              style: TextStyle(
                  fontFamily: "Canela", fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
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
                Share.share(video.videoUrl, subject: 'Check out this video!');
              },
              icon: const FaIcon(
                FontAwesomeIcons.share,
                color: Colors.white,
                size: 25,
              ),
            ),
            const Text(
              "Share",
              style: TextStyle(
                  fontFamily: "Canela", fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
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
              onPressed: () async {
                if (viewmodel.user!.guest) {
                  showToast("Please login to comment");
                  routerDelegate.beamToNamed("/login");
                  return;
                }
                if (isLiked) {
                  await viewmodel.removeLike(video.id, index);
                } else {
                  await viewmodel.addLike(video.id, index);
                  viewmodel.notifyListeners();
                }
              },
              icon: FaIcon(
                FontAwesomeIcons.solidHeart,
                color: isLiked ? Colors.pink : Colors.white,
                size: 25,
              ),
            ),
            Text(
              "${video.likes.length}",
              style: const TextStyle(
                  fontFamily: "Canela", fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
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
                showCommentSection(context, viewmodel, video);
              },
              icon: const FaIcon(
                FontAwesomeIcons.comment,
                color: Colors.white,
                size: 26,
              ),
            ),
            Text(
              "${video.comments.length}",
              style: const TextStyle(
                  fontFamily: "Canela", fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      Positioned(
        left: 15,
        bottom: 70,
        child: Text(
          video.creatorName,
          style: GoogleFonts.zillaSlab(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
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

showCommentSection(BuildContext context, HomeViewModel model, Video video) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Form(
          key: model.formKey,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Comments",
                          style: TextStyle(
                              fontFamily: "Canela",
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.times,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: video.comments.isEmpty
                          ? const Center(
                              child: Text(
                              "No comments yet",
                              style: TextStyle(
                                  fontFamily: "Canela",
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ))
                          : ListView.builder(
                              itemCount: video.comments.length,
                              itemBuilder: (context, index) {
                                final data = jsonDecode(video.comments[index]);
                                log("data: $data");
                                return ListTile(
                                    onLongPress: () {
                                      if (model.user!.guest) {
                                        return;
                                      }
                                      if (data['user']['email'] == model.user?.email) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Delete Comment"),
                                                content: const Text(
                                                    "Are you sure you want to delete this comment?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("No")),
                                                  TextButton(
                                                      onPressed: () async {
                                                        await model.deleteComment(
                                                            context, video.comments, video.id, data);
                                                        Navigator.pop(context);
                                                        // Navigator.pop(context);
                                                        model.notifyListeners();
                                                      },
                                                      child: const Text("Yes")),
                                                ],
                                              );
                                            });
                                      }
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(data['user']['photoUrl'].toString()),
                                    ),
                                    title: Text(
                                      data['user']['name'].toString(),
                                      style: const TextStyle(
                                          fontFamily: "Canela",
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      data['data']?['comment'].toString() ?? "",
                                      style: const TextStyle(
                                        fontFamily: "Canela",
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: Text(
                                      data['data']?['createdAt'].toString() ?? "",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    ));
                              },
                            ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(model.user!.photoUrl),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: model.commentController,
                            decoration: const InputDecoration(
                              hintText: "Add a comment",
                              hintStyle: TextStyle(
                                  fontFamily: "Canela",
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a comment";
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              if (model.user!.guest) {
                                showToast("Please login to comment");
                                routerDelegate.beamToNamed("/login");
                                return;
                              }
                              if (model.formKey.currentState!.validate()) {
                                model.addComment(context, video.comments, video.id);
                              }
                            },
                            icon: const FaIcon(
                              FontAwesomeIcons.solidPaperPlane,
                              color: Colors.black,
                              size: 20,
                            ))
                      ],
                    ),
                  ],
                )),
          ),
        );
      });
    },
  );
}
