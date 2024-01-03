import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/routes.dart';
import 'package:zubizubi/data/models/chat.dart';
import 'package:zubizubi/utils/appbar/appbar.dart';
import 'package:zubizubi/utils/bottom_bar.dart';
import 'package:zubizubi/views/chats/chats_viewmodel.dart';
import 'dart:developer';

import '../../../data/models/user.dart';
import '../../../themes/images.dart';

class RoomScreen extends StatelessWidget {
  Map<String, dynamic> receiver;
  RoomScreen({super.key, required this.receiver});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ChatsViewModel(),
      onViewModelReady: (viewModel) {
        // viewModel.parseCurrentReceiver(receiver['receiver']);
        log("receiver: ${receiver["receiver"]}");
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
              child: Text(viewModel.error.toString(),
                  style: TextStyle(color: Colors.white)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              routerDelegate.popToNamed('/chats');
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            )),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${receiver["receiver"].userName}",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: viewModel.roomMessages.isEmpty
                      ? Center(
                          child: Text(
                          "Messages are end to end and can only be read by\n you and ${receiver["receiver"].userName}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ))
                      : ListView.builder(
                          itemCount: viewModel.roomMessages.length,
                          itemBuilder: (context, index) {
                            log("chatRooms: ${viewModel.chatRooms.length}");
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  viewModel.roomMessages[index].sender ==
                                          viewModel.user!.name
                                      ? Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Text(
                                                viewModel.roomMessages[index]
                                                    .message,
                                                style: GoogleFonts.inter(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Text(
                                                viewModel.roomMessages[index]
                                                    .message,
                                                style: GoogleFonts.inter(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          // width: MediaQuery.of(context).size.width * 0.7,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "Type a message",
                                  hintStyle: GoogleFonts.inter(
                                      color: Colors.grey, fontSize: 14),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          Icons.send,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          bottomNavigationBar: ShellBottomNavigationBar(),
        );
      },
    );
  }
}
