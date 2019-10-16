import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/di/home_page_injections.dart';
import 'package:flutter_tess_todo/repository/models.dart';
import 'package:flutter_tess_todo/repository/user_repository.dart';

abstract class CommonContract {
  void newWidgetList(List<Widget> stream);
}

class CommonPresenter {
  CommonContract _view;

  UserRepository _userRepository;

  CommonPresenter(this._view) {
    _userRepository = new Injector().userRepositoryState;
  }

  initDataStream() async {
    Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(_userRepository.uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_COMMON_TASKS)
        .orderBy(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE)
        .snapshots()
        .asBroadcastStream()
        .listen((data) {
      var widgetTodoList = <Widget>[];
      data.documents.forEach((element) {
        var card = FirebaseDocCard(element, _userRepository.uid);
        if (card.type == CardType.TYPE_COMMON_PAGE) {
          widgetTodoList.add(card.getCommonCardFirebaseItem());
        }
      });
      _view.newWidgetList(widgetTodoList);
    });
  }

  getCommonTodo(String documentID) async {
    DocumentSnapshot ref = await Firestore.instance.collection(FIRE_BASE_ROUTE_SHARED_TODO).document(documentID).get();
    var todoColor;
    var todoName;
    var itemsArray = Map<String, Map<String, bool>>();
    ref.data.forEach((fieldName, innerTaskMap) {
      if (fieldName == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_NAME) {
        todoName = innerTaskMap.toString();
      }
      if (fieldName == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR) {
        todoColor = innerTaskMap.toString();
      }
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
    Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(_userRepository.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_COMMON_TASKS).document(todoName).setData({
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR: todoColor,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE: DateTime.now().millisecondsSinceEpoch,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS: itemsArray,
    });
    Firestore.instance.collection(FIRE_BASE_ROUTE_SHARED_TODO).document(documentID).delete();
  }
}
