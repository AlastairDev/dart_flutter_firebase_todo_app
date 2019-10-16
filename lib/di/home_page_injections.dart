import 'package:flutter_tess_todo/repository/firebase_repository.dart';
import 'package:flutter_tess_todo/repository/user_repository.dart';

class Injector {

  static final Injector _singleton = new Injector._internal();

  static UserRepository userRepositoryInitState = UserRepository();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  UserRepository get userRepositoryState {
    return userRepositoryInitState;
  }

  FirebaseRepository get firebaseRepository {
    return new FirebaseRepository();
  }
}
