import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/pages/login/login_model_presenter.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements LoginContract {
  LoginPresenter _presenter;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String message = "loading...";

  _LoginPageState() {
    _presenter = LoginPresenter(this);
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _presenter.logIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(child: Text(message)),
      ),
    );
  }

  @override
  void loggedIn() {
    Navigator.of(context).pushNamedAndRemoveUntil(PAGE_HOME, (Route<dynamic> route) => false);
  }

  @override
  void error(String error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(error),
      duration: Duration(minutes: 5),
      action: SnackBarAction(
          label: "Retry",
          onPressed: () {
            _presenter.logIn();
          }),
    ));
  }
}
