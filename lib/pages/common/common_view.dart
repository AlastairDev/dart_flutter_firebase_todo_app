import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/pages/common/common_model_presenter.dart';
import 'package:flutter_tess_todo/utils/utils.dart';
import 'package:unicorndial/unicorndial.dart';

class CommonPage extends StatefulWidget {
  CommonPage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _CommonPageState createState() => _CommonPageState();
}

class _CommonPageState extends State<CommonPage> implements CommonContract {
  CommonPresenter _presenter;
  Widget _body = Center(child: CircularProgressIndicator(backgroundColor: Colors.blue));

  _CommonPageState() {
    _presenter = CommonPresenter(this);
  }

  @override
  void initState() {
    if (widget.id != null) {
      _presenter.getCommonTodo(widget.id);
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
              contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
              title: Text("TODO added"),
            ),
      );
    }
    _presenter.initDataStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(context),
      body: _body,
      floatingActionButton: _getFAB(context),
    );
  }

  TextEditingController itemController = new TextEditingController();

  _getFAB(BuildContext context) {
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Id",
        currentButton: FloatingActionButton(
          heroTag: "id",
          backgroundColor: AppColorsMainTheme.MAIN_APP_THEME_COLOR,
          mini: true,
          child: Icon(
            Icons.insert_drive_file,
            color: Colors.black,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Row(
                    children: <Widget>[
                      Expanded(
                        child: new TextField(
                          autofocus: true,
                          decoration: InputDecoration(border: new OutlineInputBorder(), labelText: "Item"),
                          controller: itemController,
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      )
                    ],
                  ),
                  actions: <Widget>[
                    ButtonTheme(
                      child: RaisedButton(
                        elevation: 3.0,
                        onPressed: () {
                          if (itemController.text != '') {
                            _presenter.getCommonTodo(itemController.text);
                          }
                          itemController.text = '';
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                        textColor: const Color(0xffffffff),
                      ),
                    )
                  ],
                );
              },
            );
          },
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "QR-code",
        currentButton: FloatingActionButton(
          heroTag: "QR-code",
          backgroundColor: AppColorsMainTheme.MAIN_APP_THEME_COLOR,
          mini: true,
          child: Icon(
            Icons.blur_on,
            color: Colors.black,
          ),
          onPressed: scan,
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "NFC",
        currentButton: FloatingActionButton(
          heroTag: "nfc",
          backgroundColor: AppColorsMainTheme.MAIN_APP_THEME_COLOR,
          mini: true,
          child: Icon(
            Icons.wifi_tethering,
            color: Colors.black,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Row(
                    children: <Widget>[Text('Todo id waiting...')],
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
          },
        )));

    return UnicornDialer(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
        parentButtonBackground: Colors.black,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(
          Icons.add,
          color: Colors.black,
        ),
        childButtons: childButtons);
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      _presenter.getCommonTodo(barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
            title: Text("The user did not grant the camera permission!"),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
            title: Text('Unknown error: $e'),
          ),
        );
      }
    } on FormatException {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
          title: Text('null (User returned using the "back"-button before scanning anything. Result)'),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
          title: Text('Unknown error: $e'),
        ),
      );
    }
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
      title: Text("Common", style: TextStyle(color: Colors.black)),
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
