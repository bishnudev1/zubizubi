import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/views/home/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, this.shareUrl}) : super(key: key);
  final String? shareUrl;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
            body: Center(child: Text("ZubiZubi-HomeScreen")),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // viewModel.share();
                viewModel.loginWithFacebook();
              },
              child: Icon(Icons.facebook),
            ));
      },
    );
  }
}
