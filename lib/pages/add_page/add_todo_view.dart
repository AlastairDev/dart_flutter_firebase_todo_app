import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/common/en_EN.dart';
import 'package:flutter_tess_todo/pages/add_page/add_todo_model_presenter.dart';

class AddTodoPage extends StatefulWidget {
  @override
  _AddTodoPageState createState() {
    return _AddTodoPageState();
  }
}

class _AddTodoPageState extends State<AddTodoPage> implements AddTodoContract {
  ColorSwatch _mainColor = Colors.lightGreen;
  TextEditingController _listNameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AddTodoPresenter _presenter;

  _AddTodoPageState() {
    _presenter = AddTodoPresenter(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(context),
      body: _getAppBody(context),
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _presenter.addToFirebase(_listNameController.text.toString(), _mainColor.value.toString());
        },
        backgroundColor: _mainColor,
      ),
    );
  }

  _getAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(builder: (context) {
        return IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        );
      }),
      title: Text(ADD_NEW_TODO),
      backgroundColor: _mainColor,
    );
  }

  _getAppBody(BuildContext context) {
    return Padding(
      padding: PADDING_ADD_TODO_GENERAL,
      child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Theme(
          data: new ThemeData(primaryColor: _mainColor, primaryColorDark: _mainColor, cursorColor: _mainColor),
          child: new TextFormField(
            decoration: InputDecoration(
              border: new OutlineInputBorder(),
              labelText: TODO_NAME,
            ),
            controller: _listNameController,
            style: TextStyle(
              fontSize: TODO_NAME_INPUT_TEXT_SIZE,
              color: _mainColor,
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            maxLength: TODO_CARD_NAME_MAX_LENGTH,
          ),
        ),
        RaisedButton(
          child: Text(
            SELECT_COLOR,
            style: TextStyle(color: Colors.white),
          ),
          color: _mainColor,
          onPressed: _openColorPicker,
        ),
      ]),
    );
  }

  _openColorPicker() async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
            title: Text(COLOR_PICKER),
            content: MaterialColorPicker(
              allowShades: false,
              selectedColor: _mainColor,
              colors: COLOR_PICKER_COLORS,
              onMainColorChange: (color) => setState(() {
                    _mainColor = color;
                    Navigator.of(context).pop();
                  }),
            ),
          ),
    );
  }

  @override
  void todoAdded() {
    _listNameController.clear();
    Navigator.pop(context);
  }

  @override
  void todoExisted() {
    _listNameController.clear();
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(THIS_TODO_ALREADY_EXIST)));
  }

  @override
  void todoNameEmpty() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(PLEASE_ENTER_A_NAME)));
  }

}
