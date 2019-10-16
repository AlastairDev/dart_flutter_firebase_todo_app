import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tess_todo/pages/share/qr_share_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/common/en_EN.dart';
import 'package:flutter_tess_todo/repository/models.dart';

class CardFirebaseItem extends StatefulWidget {
  final int color;
  final String title;
  final bool isOpen;
  final bool isEmpty;
  final List<InnerTodoModel> innerList;
  final String uid;

  CardFirebaseItem({Key key, this.color, this.title, this.innerList, this.uid, this.isOpen, this.isEmpty});

  @override
  _CardFirebaseItemState createState() => _CardFirebaseItemState();
}

class _CardFirebaseItemState extends State<CardFirebaseItem> {
  static const platform = const MethodChannel('flutter.native/helper');
  TextEditingController itemController = new TextEditingController();
  TextEditingController renameController = new TextEditingController();
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1000),
        child: Card(
          color: Color(widget.color),
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
        if (!widget.isEmpty) {
          _changeTodoOpen(widget.title, !widget.isOpen);
        }
      },
    );
  }

  _headerBodyDivider() {
    if (widget.isOpen) {
      return Divider(height: 4);
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  _getBody() {
    if (widget.isOpen) {
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
          Text(
            innerElement.text,
            style: TextStyle(
              decoration: innerElement.isComplete ? TextDecoration.lineThrough : TextDecoration.underline,
            ),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                value: innerElement.isComplete,
                onChanged: (bool value) {
                  changeInnerTodo(widget.uid, widget.title, innerElement.text, value);
                },
              ),
              GestureDetector(
                child: Icon(
                  Icons.delete,
                ),
                onTap: () {
                  removeInnerTodoDialog(widget.uid, widget.title, innerElement.text);
                },
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
        child: Icon(Icons.add),
        onTap: () {
          _showAddInnerTodoDialog(widget.title);
        },
      ),
    );
    list.add(
      GestureDetector(
        child: Icon(Icons.check),
        onTap: () {
          setState(() {
            _visible = false;
          });
          _completeTodo(documentID);
        },
      ),
    );
    list.add(
      PopupMenuButton(
        icon: Icon(Icons.more_vert, color: Colors.black),
        onSelected: (selected) {
          if (selected == 1) {
            _renameTodoDialog(widget.title);
          }
          if (selected == 2) {
            _openColorPicker(widget.title);
          }
          if (selected == 3) {
            _shareTodo(widget.uid, widget.title);
          }
          if (selected == 4) {
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
                  trailing: Icon(Icons.edit),
                  title: Text('Rename'),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  trailing: Icon(Icons.color_lens),
                  title: Text('Change color'),
                ),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: ListTile(
                  trailing: Icon(Icons.share),
                  title: Text('Share'),
                ),
              ),
              PopupMenuItem<int>(
                value: 4,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: list,
        ),
      ],
    );
  }

  _getSwitchIcon() {
    List<Widget> list = List<Widget>();
    if (!widget.isEmpty) {
      if (widget.isOpen) {
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

  _renameTodoDialog(String documentID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              Expanded(
                child: new TextField(
                  autofocus: true,
                  controller: renameController,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLength: TODO_INNER_NAME_MAX_LENGTH,
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
                  if (renameController.text != '') {
                    _renameTodo(documentID, renameController.text);
                  } else {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
                            title: Text("Can not be empty"),
                          ),
                    );
                  }
                  itemController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text('Rename'),
                textColor: const Color(0xffffffff),
              ),
            )
          ],
        );
      },
    );
  }

  _deleteTodo(String documentID) async {
    await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(documentID).delete();
  }

  _renameTodo(String oldId, String newId) async {
    bool isExist = false;
    QuerySnapshot query = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).getDocuments();
    query.documents.forEach((doc) {
      if (newId == doc.documentID) {
        isExist = true;
      }
    });
    if (!isExist) {
      var docData = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(oldId).get();
      await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(oldId).delete();
      await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(newId).setData(docData.data);
    }else{
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
          title: Text("Already exist"),
        ),
      );
    }


  }

  _completeTodo(String documentID) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(widget.uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .document(documentID)
        .updateData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_COMPLETED: true});
  }

  _changeTodoColor(String documentID, int color) async {
    await Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(widget.uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .document(documentID)
        .updateData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR: color});
  }

  _changeTodoOpen(String documentID, bool isOpen) async {
    await Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(widget.uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .document(documentID)
        .updateData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_OPEN: isOpen});
  }

  _openColorPicker(String documentID) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
            title: Text(COLOR_PICKER),
            content: MaterialColorPicker(
              allowShades: false,
              selectedColor: Color(widget.color),
              colors: COLOR_PICKER_COLORS,
              onMainColorChange: (color) => setState(() {
                    _changeTodoColor(documentID, color.value);
                    Navigator.of(context).pop();
                  }),
            ),
          ),
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
    showDialog(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
              title: Text(widget.title),
              children: <Widget>[
                ListTile(
                  title: Text("Copy share id"),
                  subtitle: Text(ref.documentID),
                  trailing: Icon(Icons.content_copy),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: ref.documentID));
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text("QR-code"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GenerateScreen(id: ref.documentID)),
                    );
                  },
                ),
                ListTile(
                  title: Text("NFC"),
                  onTap: () {
                    _sendTodoId(ref.documentID);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text("Cancel"),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  _sendTodoId(String id) async {
//    final bool result =
    await platform.invokeMethod('sendTodoId', {"id": id});
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
            title: Text("Added to send"),
          ),
    );
//    if (result) {
//      showDialog(
//        context: context,
//        builder: (dialogCtx) => AlertDialog(
//              contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
//              title: Text("Connect to other device"),
//            ),
//      );
//    } else {
//      showDialog(
//        context: context,
//        builder: (dialogCtx) => AlertDialog(
//              contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
//              title: Text("NFC not enabled"),
//            ),
//      );
//    }
  }

  _showAddInnerTodoDialog(String documentID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              Expanded(
                child: new TextField(
                  autofocus: true,
                  decoration: InputDecoration(border: new OutlineInputBorder(), labelText: "TODO card name:", contentPadding: EdgeInsets.only(left: 16.0, top: 20.0, right: 16.0, bottom: 5.0)),
                  controller: itemController,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLength: TODO_INNER_NAME_MAX_LENGTH,
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
                    _addInnerTodo(documentID, itemController.text);
                  } else {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                            contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
                            title: Text("Can not be empty"),
                          ),
                    );
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
  }

  _addInnerTodo(String documentID, String innerTodo) async {
    var innerList = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(documentID).get();
    var itemsArray = Map<String, Map<String, bool>>();
    innerList.data.forEach((fieldName, innerTaskMap) {
      if (fieldName == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS) {
        (innerTaskMap as Map<dynamic, dynamic>).forEach((name, map) {
          (map as Map<dynamic, dynamic>).forEach((date, isDone) {
            itemsArray.addAll({
              name: {date: isDone}
            });
          });
        });
      }
    });
    var isExist = false;
    itemsArray.forEach((key, item) {
      if (key == innerTodo) isExist = true;
    });
    if (!isExist) {
      itemsArray.addAll({
        innerTodo: {DateTime.now().millisecondsSinceEpoch.toString(): false}
      });
      await Firestore.instance
          .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
          .document(widget.uid)
          .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
          .document(documentID)
          .setData({FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS: itemsArray}, merge: true).whenComplete(() {
        _changeTodoOpen(documentID, true);
      });
    } else {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
              contentPadding: PADDING_ADD_TODO_COLOR_PICKER,
              title: Text("Already exist"),
            ),
      );
    }
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

  void removeInnerTodoDialog(String uid, String documentID, String innerTodo) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("confirm todo removal"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, 1),
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                removeInnerTodo(uid, documentID, innerTodo);
                Navigator.pop(context, 2);
              },
            ),
          ],
        ));

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
      if (itemsArray.isEmpty) {
        _changeTodoOpen(documentID, false);
      } else {
        _changeTodoOpen(documentID, true);
      }
    });
  }
}
