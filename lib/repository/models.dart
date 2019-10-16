import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/pages/widgets/common_card_item.dart';
import 'package:flutter_tess_todo/pages/widgets/history_card_item.dart';

class InnerTodoModel {
  String text;
  bool isComplete;
  double time;

  InnerTodoModel({
    this.time,
    this.text,
    this.isComplete,
  });
}

enum CardType { TYPE_MAIN_PAGE, TYPE_COMMON_PAGE, TYPE_HISTORY_PAGE }

class FirebaseDocCard {
  var documentID;
  var uid;
  var elementColor;
  var type;
  var isOpen;
  var innerTasks = List<InnerTodoModel>();

  FirebaseDocCard(DocumentSnapshot documentSnapshot, this.uid) {
    documentID = documentSnapshot.documentID;
    documentSnapshot.data.forEach((a, b) {
      if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR) elementColor = int.parse(b.toString());
      if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_COMPLETED) {
        if (b.toString().toLowerCase() == true.toString().toLowerCase()) {
          type = CardType.TYPE_HISTORY_PAGE;
        } else {
          type = CardType.TYPE_MAIN_PAGE;
        }
      }
      if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_OPEN) isOpen = b.toString().toLowerCase() == true.toString().toLowerCase();
      if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS)
        (b as Map<dynamic, dynamic>).forEach((d, e) {
          (e as Map<dynamic, dynamic>).forEach((date, val) {
            innerTasks.add(InnerTodoModel(text: d.toString(), isComplete: val.toString().toLowerCase() == true.toString().toLowerCase(), time: double.parse(date.toString())));
          });
        });
    });
    if(type == null){
      type = CardType.TYPE_COMMON_PAGE;
    }
    innerTasks.sort((firstElement, secondElement) => firstElement.time.compareTo(secondElement.time));
  }

  CommonCardFirebaseItem getCommonCardFirebaseItem() {
    return CommonCardFirebaseItem(
      key: Key(documentID),
      isEmpty: innerTasks.isEmpty,
      isOpen: isOpen,
      color: elementColor,
      title: documentID,
      innerList: innerTasks,
      uid: uid,
    );
  }

  HistoryCardFirebaseItem getHistoryCardFirebaseItem() {
    return HistoryCardFirebaseItem(
      key: Key(documentID),
      isEmpty: innerTasks.isEmpty,
      isOpen: isOpen,
      color: elementColor,
      title: documentID,
      innerList: innerTasks,
      uid: uid,
    );
  }
}
