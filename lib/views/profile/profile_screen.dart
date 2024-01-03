import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/themes/images.dart';
import 'package:zubizubi/utils/appbar/appbar.dart';
import 'package:zubizubi/views/profile/profile_viewmodel.dart';

import '../../utils/bottom_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // BeamerDelegate? _beamerDelegate;
  @override
  Widget build(BuildContext context) {

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onViewModelReady: (viewModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await viewModel.getUser();
          viewModel.getUserVideos(viewModel.user?.email ?? "");
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
        return Scaffold(
          appBar: PreferredSize(preferredSize: Size.fromHeight(50), child: CustomAppBar()),
          body: SafeArea(
              child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration:
                BoxDecoration(image: DecorationImage(image: AssetImage(Images.appBg), fit: BoxFit.cover)),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            NetworkImage(viewModel.user?.photoUrl ?? "https://picsum.photos/200"),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: FaIcon(
                                FontAwesomeIcons.userPlus,
                                color: Colors.white,
                                size: 18,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.report,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        "${viewModel.user?.name ?? ""}",
                        style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 15,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: Text(
                //     "Email: ${viewModel.user?.email ?? ""}",
                //     style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
                //   ),
                // ),
                // SizedBox(
                //   height: 5,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${viewModel.user?.bio ?? ""}",
                        style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          viewModel.editBio(context);
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Beamer.of(context).beamToNamed('/followers');
                          // viewModel.goToFollowersScreen();
                          // _beamerDelegate!.beamToNamed('/followers');
                        },
                        child: Text(
                          "Followers: ${viewModel.user?.followers.length ?? 0}",
                          style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Shares: ${viewModel.user?.shares.length ?? 0}",
                        style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            viewModel.changeImage(context);
                          },
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent),
                            child: viewModel.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1,
                                  )
                                : Text(
                                    "Update Picture",
                                    style: GoogleFonts.lato(fontSize: 14, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            viewModel.logout(context);
                          },
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent),
                            child: Text(
                              "Logout Profile",
                              style: GoogleFonts.lato(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 videos in a row
                      crossAxisSpacing: 1.0, // Adjust as needed
                      mainAxisSpacing: 1.0, // Adjust as needed
                    ),
                    itemCount: viewModel.userVideos.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Beamer.of(context)
                          //     .beamToNamed('/share', data: {'shareUrl': viewModel.userVideos[index].videoUrl});
                          routerDelegate.beamToNamed('/share?url=${viewModel.userVideos[index].videoUrl}',);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(10)
                            ),
                            width: MediaQuery.of(context).size.width * 0.3, // Adjust as needed
                            height: 700, // Adjust as needed
                            child: Center(
                              child: Text("${viewModel.userVideos[index].name}}"),
                            )),
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
          bottomNavigationBar: const ShellBottomNavigationBar(),
        );
      },
    );
  }
}
