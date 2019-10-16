import 'package:flutter/material.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/pages/settings/settings_model_presenter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() {
    return new SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> implements SettingsContract {
  bool _checkBoxVal = true;
  SharedPreferences _prefs;
  SettingsPresenter _presenter;

  @override
  void initState() {
    SharedPreferences.getInstance()
      ..then((prefs) {
        setState(() {
          this._prefs = prefs;
          _checkBoxVal = _prefs.getBool(PREF_USER_SETTINGS_USE_HORIZONTAL_FAB) ?? true;
        });
      });
    _presenter = SettingsPresenter(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: __getAppBar(context),
      body: __getAppBody(context),
    );
  }

  __getAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(builder: (context) {
        return IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        );
      }),
      title: Text("Settings"),
      backgroundColor: AppColorsMainTheme.MAIN_APP_THEME_COLOR,
      elevation: 1.0,
    );
  }

  __getAppBody(BuildContext context) {
    return SafeArea(
        child: ListView(
      children: __getSettingsList(context),
    ));
  }

  __getSettingsList(BuildContext context) {
    return <Widget>[
      //sample
//      ListTile(
//        title: Text("Use horizontal FAB's orientation"),
//        trailing: Checkbox(
//            value: _checkBoxVal,
//            onChanged: (bool value) {
//              __setIsHorizontalFab(value);
//            }),
//      ),
      Divider(),
      RaisedButton(
        child: Text("Sign Out"),
        onPressed: () {
          _presenter.logOut();
        },
      ),
    ];
  }

  __getIsHorizontalFab() {
    setState(() {
      _checkBoxVal = _prefs.getBool(PREF_USER_SETTINGS_USE_HORIZONTAL_FAB) ?? true;
    });
  }

  Future<Null> __setIsHorizontalFab(val) async {
    await _prefs.setBool(PREF_USER_SETTINGS_USE_HORIZONTAL_FAB, val);
    __getIsHorizontalFab();
  }

  @override
  void error(String error) {}

  @override
  void loggedOut() {
    Navigator.pushNamedAndRemoveUntil(context, PAGE_LOGIN, (_) => false);
  }
}
