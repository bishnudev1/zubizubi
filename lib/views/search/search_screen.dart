import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
              children: [
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: viewModel.searchController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        viewModel.searchList = [];
                        viewModel.notifyListeners();
                      } else {
                        viewModel.searchUsers();
                        viewModel.notifyListeners();
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search a user...",
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.searchList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(viewModel.searchList[index].photoUrl!),
                                      fit: BoxFit.cover),
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 10,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 10,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                                ),
                              ],
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
        );
      },
    );
  }
}
