import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../splash/splash_viewmodel.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SplashViewModel(),
      onViewModelReady: (viewModel) {
        viewModel.init(context);
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Center(child: Image.asset("assets/images/icon.jpeg", height: 100, width: 100,)),
        );
      },
    );
  }
}
