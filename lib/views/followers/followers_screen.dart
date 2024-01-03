import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/themes/images.dart';
import 'package:zubizubi/utils/bottom_bar.dart';
import 'package:zubizubi/views/followers/followers_viewmodel.dart';

import '../../utils/appbar/appbar.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => FollowersViewModel(),
      onViewModelReady: (viewModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await viewModel.getUser();
          await viewModel.getFollowers();
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
              preferredSize: Size.fromHeight(50), child: CustomAppBar()),
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Images.appBg), fit: BoxFit.cover)),
              child: ListView.builder(
                itemCount: viewModel.followersList.length,
                itemBuilder: (context, index) {
                  return viewModel.followersList.isEmpty
                      ? Center(
                          child: Text(
                            "You are not following anyone yet",
                            style: GoogleFonts.labrada(
                                fontSize: 20,
                                // fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      : ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(""),
                          ),
                          title: Text(""),
                          subtitle: Text(""),
                          trailing: Text(""),
                        );
                },
              ),
            ),
          ),
          bottomNavigationBar: const ShellBottomNavigationBar(),
        );
      },
    );
  }
}
