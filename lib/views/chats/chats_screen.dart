import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/themes/images.dart';
import 'package:zubizubi/utils/appbar/appbar.dart';
import 'package:zubizubi/utils/bottom_bar.dart';
import 'package:zubizubi/views/chats/chats_viewmodel.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ChatsViewModel(),
      onViewModelReady: (viewModel) {
        log("viewModel.chatRooms.isEmpty: ${viewModel.chatRooms.isEmpty}");
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
              child: Text(viewModel.error.toString(), style: const TextStyle(color: Colors.white)),
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
              child: viewModel.chatRooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.solidCommentDots,
                            color: Colors.white,
                            size: 50,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "You have no chats yet",
                            style: GoogleFonts.labrada(
                                fontSize: 20,
                                // fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: viewModel.chatRooms.length,
                      itemBuilder: (context, index) {
                        log("chatRooms: ${viewModel.chatRooms.length}");
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            onTap: () {
                              routerDelegate
                                  .beamToNamed("/room", data: {"receiver": viewModel.chatRooms[index]});
                            },
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(viewModel.chatRooms[index].userImage),
                            ),
                            title: Text(
                              viewModel.chatRooms[index].userName,
                              style: GoogleFonts.labrada(
                                  fontSize: 20,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            subtitle: Text(
                              viewModel.chatRooms[index].lastMessage,
                              style: GoogleFonts.labrada(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            trailing: Text(
                              viewModel.chatRooms[index].lastMessageTime,
                              style: GoogleFonts.labrada(
                                  fontSize: 15,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
