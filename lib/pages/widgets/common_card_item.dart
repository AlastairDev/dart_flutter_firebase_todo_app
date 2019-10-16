import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/repository/models.dart';

class CommonCardFirebaseItem extends StatefulWidget {
  final int color;
  final String title;
  final List<InnerTodoModel> innerList;
  final String uid;

  CommonCardFirebaseItem({Key key, this.color, this.title, this.innerList, this.uid, bool isEmpty, isOpen});

  @override
  _CommonCardFirebaseItemState createState() => _CommonCardFirebaseItemState();
}

class _CommonCardFirebaseItemState extends State<CommonCardFirebaseItem> {
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
          _addTodo(widget.uid, documentID);
        },
      ),
    );
    list.add(
      GestureDetector(
        child: Icon(Icons.delete),
        onTap: () {
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
        },
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

  _addTodo(String uid, String documentID) async {
    var innerList = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_COMMON_TASKS).document(documentID).get();
    Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_COMMON_TASKS).document(documentID).delete();
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
    Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(documentID).setData({
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_COMPLETED: false,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_OPEN: false,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR: widget.color,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE: DateTime.now().millisecondsSinceEpoch,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS: itemsArray,
    });
  }

  _deleteTodo(String documentID) async {
    await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(widget.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_COMMON_TASKS).document(documentID).delete();
  }
}
