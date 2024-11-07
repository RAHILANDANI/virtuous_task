import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../servicies/authentication.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthHelper _authHelper = AuthHelper();
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String?> _loginUser(LoginData data) async {
    String? error = await _authHelper.loginWithEmailPassword(data.name, data.password);
    if (error == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
    }
    return error;
  }

  Future<String?> _signUpUser(SignupData data) async {
    String? error = await _authHelper.signUpWithEmailPassword(data.name!, data.password!);
    if (error == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
    }
    return error;
  }

  Future<String?> _loginWithGoogle() async {
    String? error = await _authHelper.loginWithGoogle();
    if (error == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      return null;
    } else {
      return error;
    }
  }

  Future<String?> _recoverPassword(String name) async {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Virtuous Task',
      onLogin: _loginUser,
      onSignup: _signUpUser,
      loginProviders: [
        LoginProvider(
          button: Buttons.google,
          label: "Google",
          callback: () async => _loginWithGoogle(),
        ),
      ],
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
      },
    );
  }
}
