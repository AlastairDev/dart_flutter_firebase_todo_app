import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/di/home_page_injections.dart';
import 'package:flutter_tess_todo/repository/models.dart';
import 'package:flutter_tess_todo/repository/user_repository.dart';

abstract class HistoryContract {
  void newWidgetList(List<Widget> stream);
}

class HistoryPresenter {
  HistoryContract _view;
  UserRepository _userRepository;

  HistoryPresenter(this._view) {
    _userRepository = new Injector().userRepositoryState;
  }

  void initDataStream() async {
    Firestore.instance
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO)
        .document(_userRepository.uid)
        .collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS)
        .orderBy(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE)
        .snapshots()
        .asBroadcastStream()
        .listen((data) {
      var widgetTodoList = <Widget>[];
      data.documents.forEach((element) {
        var card = FirebaseDocCard(element, _userRepository.uid);
        if (card.type == CardType.TYPE_HISTORY_PAGE) {
          widgetTodoList.add(card.getHistoryCardFirebaseItem());
        }
      });
      _view.newWidgetList(widgetTodoList);
    });
  }
}
