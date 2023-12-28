import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import 'package:zubizubi/services/auth_services.dart';

class LoginViewModel extends ReactiveViewModel {
  final _authServices = locator<AuthServices>();
  loginWithFacebook() async {
    await _authServices.handleFacebookLogin();
  }

  loginWithGoogle() async {
    await _authServices.handleGoogleLogin();
  }
}
