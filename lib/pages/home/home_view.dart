import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/pages/home/home_model_presenter.dart';
import 'package:flutter_tess_todo/pages/widgets/bottom_bar_with_fab.dart';
import 'package:flutter_tess_todo/utils/utils.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> implements HomeContract {
  HomePresenter _presenter;
  static const nativeMethodChannel = const MethodChannel('flutter.native/helper');
  Widget _body = Center(child: Text("data loading..."));

  _HomePageState() {
    _presenter = HomePresenter(this);
  }

  @override
  void initState() {
    nativeMethodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case LAUNCH_TYPE_ADD_TODO:
          {
            _presenter.copyCommonTodo(call.arguments);
            return;
          }
      }
    });
    _presenter.initDataStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _getAppBar(), body: _body, floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, floatingActionButton: _getFAB(), bottomNavigationBar: _getBottomNavigationBar());
  }

  @override
  void todoCopy(bool isSuccess, String todoId) {
    if (isSuccess) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: <Widget>[Text(todoId)],
            ),
            actions: <Widget>[
              ButtonTheme(
                child: RaisedButton(
                  elevation: 3.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                  textColor: const Color(0xffffffff),
                ),
              )
            ],
          );
        },
      );
    }
  }

  Widget _getBottomNavigationBar() {
    return FABBottomAppBar(
      notchedShape: CircularNotchedRectangle(),
      onTabSelected: (pos) {
        switch (pos) {
          case 0:
            Navigator.of(context).pushNamed(PAGE_HISTORY);
            break;
          case 1:
            Navigator.of(context).pushNamed(PAGE_COMMON);
            break;
        }
      },
      items: [
        FABBottomAppBarItem(iconData: Icons.history, text: 'History'),
        FABBottomAppBarItem(iconData: Icons.group, text: 'Сommon'),
      ],
    );
  }

  Widget _getFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed(PAGE_ADD);
      },
      tooltip: 'Add',
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      elevation: 2.0,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }

  Widget _getAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          radius: 18,
          child: ClipOval(
            child: Image.network(
              _presenter.getAvatarUrl(),
            ),
          ),
        ),
      ),
      title: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(_presenter.getUserName(), style: TextStyle(color: Colors.black,fontSize: 22)),
            Text(_presenter.getEmail(), style: TextStyle(color: Colors.black,fontSize: 14)),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (selected) {
              if (selected == 1) {
                _presenter.logOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('Logout'),
                  ),
                ],
          ),
        ),
      ],
    );
  }

  @override
  void error(String error) {}

  @override
  void loggedOut() {
    Navigator.pushNamedAndRemoveUntil(context, PAGE_LOGIN, (_) => false);
  }

  @override
  void newWidgetList(List<Widget> stream) {
    setState(() {
      _body = ListView.builder(
        itemCount: stream.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == stream.length-1) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 36.0),
              child: stream[index],
            );
          } else {
            return stream[index];
          }
        },
      );
    });
  }
}
