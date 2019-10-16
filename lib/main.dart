import 'package:flutter/material.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/pages/common/common_view.dart';
import 'package:flutter_tess_todo/pages/history/history_view.dart';
import 'package:flutter_tess_todo/pages/add_page/add_todo_view.dart';
import 'package:flutter_tess_todo/pages/home/home_view.dart';
import 'package:flutter_tess_todo/pages/login/login_view.dart';
import 'package:flutter_tess_todo/pages/settings/settings_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      initialRoute: PAGE_LOGIN,
      routes: {
        PAGE_HOME: (context) => HomePage(),
        PAGE_LOGIN: (context) => LoginPage(),
        PAGE_ADD: (context) => AddTodoPage(),
        PAGE_HISTORY: (context) => HistoryPage(),
        PAGE_SETTINGS: (context) => SettingsPage(),
        PAGE_COMMON: (context) => CommonPage(),
      },
    );
  }
}
