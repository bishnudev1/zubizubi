

import 'package:stacked/stacked.dart';
import 'package:zubizubi/app/app.locator.dart';
import '../../services/auth_services.dart';

class HomeViewModel extends BaseViewModel{
  final _authServices = locator<AuthServices>();

  loginWithFacebook() async {
    await _authServices.handleFacebookLogin();
  }
}