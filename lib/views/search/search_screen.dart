import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/themes/images.dart';
import 'package:zubizubi/utils/bottom_bar.dart';
import 'package:zubizubi/views/search/search_viewmodel.dart';

import '../../utils/appbar/appbar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SearchViewModel(),
      onViewModelReady: (viewModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await viewModel.getUser();
          await viewModel.getAllUsers();
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
          appBar: const PreferredSize(preferredSize: Size.fromHeight(50), child: CustomAppBar()),
          body: SafeArea(
              child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage(Images.appBg), fit: BoxFit.cover)),
            child: Column(
              children: [
                Container(
                  // height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: TextFormField(
                    controller: viewModel.searchController,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        viewModel.searchList = [];
                        viewModel.notifyListeners();
                      } else {
                        viewModel.searchUsers();
                        viewModel.notifyListeners();
                      }
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search a user...",
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.searchList.length,
                    itemBuilder: (context, index) {
                      final userFollowers = viewModel.searchList[index];

                      final myFollowers = viewModel.user?.followers;

                      log("userFollowers: $userFollowers");
                      log("myFollowers: $myFollowers");

                      final isContains = myFollowers!.contains(userFollowers.email);

                      final isMe = viewModel.user?.email == userFollowers.email;

                      log("isContains: $isContains");

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(viewModel.searchList[index].photoUrl),
                                      fit: BoxFit.cover),
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewModel.searchList[index].name,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    viewModel.searchList[index].email,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                log("followUser");
                                if (isContains) {
                                  viewModel.unfollowUser(
                                    viewModel.searchList[index].email,
                                    viewModel.user!.followers,
                                    viewModel.user!.id,
                                  );
                                } else {
                                  viewModel.followUser(
                                    viewModel.searchList[index].email,
                                    viewModel.user!.followers,
                                    viewModel.user!.id,
                                  );
                                }
                                if (isMe) {
                                  return;
                                }
                                viewModel.notifyListeners();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                height: 30,
                                // width: 80,
                                decoration: BoxDecoration(
                                    color: isContains ? Colors.white : Colors.pinkAccent,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: isMe
                                      ? Text(
                                          "You",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        )
                                      : isContains
                                          ? Text(
                                              "Unfollow",
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                color: Colors.pinkAccent,
                                              ),
                                            )
                                          : Text(
                                              "Follow",
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )),
          //   bottomNavigationBar: const ShellBottomNavigationBar(),
        );
      },
    );
  }
}
