import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';
import 'package:flutter_tess_todo/di/home_page_injections.dart';
import 'package:flutter_tess_todo/repository/firebase_repository.dart';
import 'package:flutter_tess_todo/repository/models.dart';
import 'package:flutter_tess_todo/pages/widgets/card_item.dart';
import 'package:flutter_tess_todo/repository/user_repository.dart';

abstract class HomeContract {
  void todoCopy(bool isSuccess, String todoId);

  void loggedOut();

  void newWidgetList(List<Widget> stream);

  void error(String error);
}

class HomePresenter {
  HomeContract _view;

  UserRepository _userRepository;
  FirebaseRepository _firebaseRepository;

  HomePresenter(this._view) {
    _userRepository = new Injector().userRepositoryState;
    _firebaseRepository = new Injector().firebaseRepository;
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
        var elementColor;
        var isCompleted;
        var isOpen;
        var innerTasks = List<InnerTodoModel>();
        element.data.forEach((a, b) {
          if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR) elementColor = int.parse(b.toString());
          if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_COMPLETED) isCompleted = b.toString().toLowerCase() == true.toString().toLowerCase();
          if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_OPEN) isOpen = b.toString().toLowerCase() == true.toString().toLowerCase();
          if (a == FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS)
            (b as Map<dynamic, dynamic>).forEach((d, e) {
              (e as Map<dynamic, dynamic>).forEach((date, val) {
                innerTasks.add(InnerTodoModel(text: d.toString(), isComplete: val.toString().toLowerCase() == true.toString().toLowerCase(), time: double.parse(date.toString())));
              });
            });
        });
        innerTasks.sort((firstElement, secondElement) => firstElement.time.compareTo(secondElement.time));

        if (!isCompleted) {
          widgetTodoList.add(new CardFirebaseItem(
            key: Key(element.documentID),
            isEmpty: innerTasks.isEmpty,
            isOpen: isOpen,
            color: elementColor,
            title: element.documentID,
            innerList: innerTasks,
            uid: _userRepository.uid,
          ));
        }
      });
      _view.newWidgetList(widgetTodoList);
    });
  }

  getEmail() {
    if(_userRepository.email!=null){
      return _userRepository.email;
    }else{
      return "";
    }
  }

  getUserName() {
    if(_userRepository.userName!=null){
      return _userRepository.userName;
    }else{
      return "";
    }
  }

  getAvatarUrl() {
    if (_userRepository.imageUrl != null) {
      return _userRepository.imageUrl;
    } else {
      return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOR1zZlDua_XWy6siLatcKpf5VliE-LmdZqQsDRXqaBPhVwcSs";
    }
  }

  copyCommonTodo(String documentID) async {
    _firebaseRepository.copySharedTodoList(documentID).then((isSuccess) {
      _view.todoCopy(isSuccess, documentID);
    });
  }

  logOut() {
    _userRepository.logOut().then((isLoggedOut) {
      if (isLoggedOut) {
        _view.loggedOut();
      } else {
        _view.error("log out error");
      }
    });
  }
}
