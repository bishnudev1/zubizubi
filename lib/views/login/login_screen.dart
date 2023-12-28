import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/views/login/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => LoginViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => viewModel.loginWithFacebook(),
                    child: const Text("Login with Facebook")),
                ElevatedButton(
                    onPressed: () => viewModel.loginWithGoogle(),
                    child: const Text("Login with Google")),
              ],
            ),
          ),
        );
      },
    );
  }
}
