import 'package:flutter/material.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/pages/history/history_model_presenter.dart';
import 'package:flutter_tess_todo/utils/utils.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> implements HistoryContract {
  HistoryPresenter _presenter;
  Widget _body = Center(child: CircularProgressIndicator(backgroundColor: Colors.blue));

  _HistoryPageState() {
    _presenter = HistoryPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    _presenter.initDataStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(context),
      body: _body,
    );
  }

  _getAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(builder: (context) {
        return IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        );
      }),
      title: Text("History", style: TextStyle(color: Colors.black)),
      backgroundColor: AppColorsMainTheme.MAIN_APP_THEME_COLOR,
      elevation: 1.0,
    );
  }

  @override
  void newWidgetList(List<Widget> stream) {
    setState(() {
      _body = ListView.builder(
        key: Key(randomString(20)),
        itemCount: stream.length,
        itemBuilder: (BuildContext context, int index) {
          return stream[index];
        },
      );
    });
  }
}
