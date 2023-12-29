import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/themes/images.dart';
import 'package:zubizubi/utils/appbar/appbar.dart';
import 'package:zubizubi/views/profile/profile_viewmodel.dart';

import '../../utils/bottom_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onViewModelReady: (viewModel) {
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
        return Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: CustomAppBar()),
          body: SafeArea(
              child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Images.appBg), fit: BoxFit.cover)),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                      "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Hello: ${viewModel.user?.name ?? ""}",
                  style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Your email: ${viewModel.user?.email ?? ""}",
                  style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Followers: ${viewModel.user?.likes ?? 0}",
                      style:
                          GoogleFonts.lato(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Shares: ${viewModel.user?.shares ?? 0}",
                      style:
                          GoogleFonts.lato(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent),
                        child: Text(
                          "Delete Profile",
                          style: GoogleFonts.lato(
                              fontSize: 14, color: Colors.white),
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
                            style: GoogleFonts.lato(
                                fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
          bottomNavigationBar: bottomNavigationBar(context),
        );
      },
    );
  }
}
