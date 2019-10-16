import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/common/en_EN.dart';
import 'package:flutter_tess_todo/repository/models.dart';

class HistoryCardFirebaseItem extends StatefulWidget {
  final int color;
  final String title;
  final List<InnerTodoModel> innerList;
  final String uid;

  HistoryCardFirebaseItem({Key key, this.color, this.title, this.innerList, this.uid, bool isEmpty, isOpen});

  @override
  _HistoryCardFirebaseItemState createState() => _HistoryCardFirebaseItemState();
}

class _HistoryCardFirebaseItemState extends State<HistoryCardFirebaseItem> {
  TextEditingController itemController = new TextEditingController();
  bool isOpen;
  bool isEmpty;
  int cardColor;

  @override
  void initState() {
    cardColor = widget.color;
    isOpen = false;
    isEmpty = widget.innerList.isEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Card(
        color: Color(cardColor),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: <Widget>[
              _getHeader(widget.innerList.length),
              _headerBodyDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
                child: _getBody(),
              ),
              _getFooter(context, widget.title),
            ],
          ),
        ),
      ),
    );
  }

  _getHeader(int size) {
    return FlatButton(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Text(
            widget.title,
            style: TextStyle(fontSize: 25.0),
          )),
          Row(children: _getSwitchIcon()),
        ],
      ),
      onPressed: () {
        if (!isEmpty) {
          setState(() {
            isOpen = !isOpen;
          });
        }
      },
    );
  }

  _headerBodyDivider() {
    if (isOpen) {
      return Divider(height: 4);
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  _getBody() {
    if (isOpen) {
      return Column(children: _getInnerWidgetList());
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  _getInnerWidgetList() {
    var innerWidget = <Row>[];
    widget.innerList.forEach((innerElement) {
      innerWidget.add(Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(innerElement.text),
          Row(
            children: <Widget>[
              Checkbox(
                tristate: true,
                value: innerElement.isComplete,
                onChanged: null,
              ),
            ],
          ),
        ],
      ));
    });
    return innerWidget;
  }

  _getFooter(BuildContext context, String documentID) {
    List<Widget> list = List<Widget>();
    list.add(Text(
      "Todo\'s : " + widget.innerList.length.toString(),
      style: TextStyle(fontWeight: FontWeight.bold),
    ));
    list.add(
      GestureDetector(
        child: Icon(Icons.chevron_left),
        onTap: () {
          _returnTodo(documentID);
        },
      ),
    );
    list.add(
      PopupMenuButton(
        icon: Icon(Icons.more_vert, color: Colors.black),
        onSelected: (selected) {
          if (selected == 1) {
            _openColorPicker(widget.title);
          }
          if (selected == 2) {
            _shareTodo(widget.uid, widget.title);
          }
          if (selected == 3) {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: Text("confirm card removal"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () => Navigator.pop(context, 1),
                        ),
                        FlatButton(
                          child: Text("Ok"),
                          onPressed: () {
                            _deleteTodo(documentID);
                            Navigator.pop(context, 2);
                          },
                        ),
                      ],
                    ));
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  trailing: Icon(Icons.color_lens),
                  title: Text('Change color'),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  trailing: Icon(Icons.share),
                  title: Text('Share'),
                ),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: ListTile(
                  trailing: Icon(Icons.delete),
                  title: Text('Delete'),
                ),
              ),
            ],
      ),
    );
    return Column(
      children: <Widget>[
        Divider(height: 4),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: list,
          ),
        ),
      ],
    );
  }

  _shareTodo(String uid, String documentID) async {
    var innerList = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(documentID).get();
    var itemsArray = Map<String, Map<String, bool>>();
    innerList.data.forEach((fieldName, innerTaskMap) {
      if (fieldName == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS) {
        (innerTaskMap as Map<dynamic, dynamic>).forEach((name, map) {
          (map as Map<dynamic, dynamic>).forEach((date, isDone) {
            itemsArray.addAll({
              name: {date: false}
            });
          });
        });
      }
    });
    DocumentReference ref = Firestore.instance.collection(FIRE_BASE_ROUTE_SHARED_TODO).document();
    Firestore.instance.collection(FIRE_BASE_ROUTE_SHARED_TODO).document(ref.documentID).setData({
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_NAME: documentID,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR: widget.color,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE: DateTime.now().millisecondsSinceEpoch,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS: itemsArray,
    });
    Clipboard.setData(new ClipboardData(text: ref.documentID));
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
            title: Text(ref.documentID),
          ),
    );
  }

  _getSwitchIcon() {
    List<Widget> list = List<Widget>();
    if (!isEmpty) {
      if (isOpen) {
        list.add(Icon(
          Icons.keyboard_arrow_up,
          size: 40,
        ));
      } else {
        list.add(Icon(Icons.keyboard_arrow_down, size: 40));
      }
    } else {
      list.add(Icon(Icons.arrow_drop_down, size: 0));
    }
    return list;
  }

  _deleteTodo(String documentID) async {
    await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(documentID).delete();
  }

  _returnTodo(String documentID) async {
    await Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(widget.uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .document(documentID)
        .updateData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_COMPLETED: false});
  }

  _changeTodoColor(String documentID, int color) async {
    await Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(widget.uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .document(documentID)
        .updateData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR: color});
  }

  _openColorPicker(String documentID) async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
            title: Text(COLOR_PICKER),
            content: MaterialColorPicker(
              allowShades: false,
              selectedColor: Color(cardColor),
              colors: COLOR_PICKER_COLORS,
              onMainColorChange: (color) => setState(() {
                    _changeTodoColor(documentID, color.value);
                    setState(() {
                      cardColor = color.value;
                    });
                    Navigator.of(context).pop();
                  }),
            ),
          ),
    );
  }

  void changeInnerTodo(String uid, String documentID, String innerTodo, bool isCompleted) async {
    var innerList = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(documentID).get();
    var itemsArray = Map<String, Map<String, bool>>();
    innerList.data.forEach((fieldName, innerTaskMap) {
      if (fieldName == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS) {
        (innerTaskMap as Map<dynamic, dynamic>).forEach((name, map) {
          (map as Map<dynamic, dynamic>).forEach((date, isDone) {
            if (name == innerTodo) {
              isDone = isCompleted;
            }
            itemsArray.addAll({
              name: {date: isDone}
            });
          });
        });
      }
    });
    await Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .document(documentID)
        .updateData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS: itemsArray});
  }

  void removeInnerTodo(String uid, String documentID, String innerTodo) async {
    var innerList = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(documentID).get();
    var itemsArray = Map<String, Map<String, bool>>();
    innerList.data.forEach((fieldName, innerTaskMap) {
      if (fieldName == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS) {
        (innerTaskMap as Map<dynamic, dynamic>).forEach((name, map) {
          (map as Map<dynamic, dynamic>).forEach((date, isDone) {
            if (name != innerTodo) {
              itemsArray.addAll({
                name: {date: isDone}
              });
            }
          });
        });
      }
    });
    await Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .document(documentID)
        .updateData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS: itemsArray}).then((onValue) {
      setState(() {
        if (widget.innerList.isEmpty) {
          isEmpty = true;
          isOpen = false;
        }
      });
    });
  }
}
