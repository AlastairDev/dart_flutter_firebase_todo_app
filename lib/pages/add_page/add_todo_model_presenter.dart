import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/di/home_page_injections.dart';
import 'package:flutter_tess_todo/repository/user_repository.dart';

abstract class AddTodoContract {
  void todoAdded();

  void todoExisted();

  void todoNameEmpty();
}

class AddTodoPresenter {
  AddTodoContract _view;

  UserRepository _userRepository;

  AddTodoPresenter(this._view) {
    _userRepository = Injector().userRepositoryState;
  }

  addToFirebase(String name, String color) async {
    name = name.trim();
    if (name == "" || name.isEmpty) {
      _view.todoNameEmpty();
    } else {
      bool isExist = false;
      QuerySnapshot query = await Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(_userRepository.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).getDocuments();
      query.documents.forEach((doc) {
        if (name == doc.documentID) {
          isExist = true;
          _view.todoExisted();
        }
      });
      if (!isExist) {
        Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(_userRepository.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS).document(name).setData({
          FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR: color,
          FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_OPEN: false,
          FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE: DateTime.now().millisecondsSinceEpoch,
          FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_COMPLETED: false
        });
        _view.todoAdded();
      }
    }
  }
}
