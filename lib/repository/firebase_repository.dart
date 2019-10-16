import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tess_todo/common/app_settings.dart';

class FirebaseRepository {
  Future<bool> copySharedTodoList(String documentID) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
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
    Firestore.instance.collection(FIRE_BASE_ROUTE_PRIVATE_TODO).document(user.uid).collection(FIRE_BASE_ROUTE_PRIVATE_TODO_COMMON_TASKS).document(todoName).setData({
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR: todoColor,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE: DateTime.now().millisecondsSinceEpoch,
      FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS: itemsArray,
    });
    Firestore.instance.collection(FIRE_BASE_ROUTE_SHARED_TODO).document(documentID).delete();
    return true;
  }
}
