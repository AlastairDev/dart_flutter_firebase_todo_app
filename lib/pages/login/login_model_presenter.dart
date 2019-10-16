import 'package:flutter_tess_todo/di/home_page_injections.dart';
import 'package:flutter_tess_todo/repository/user_repository.dart';

abstract class LoginContract {
  void loggedIn();
  void error(String error);
}

class LoginPresenter {
  LoginContract _view;

  UserRepository _userRepository;

  LoginPresenter(this._view) {
    _userRepository = Injector().userRepositoryState;
  }

  logIn() {
    _userRepository.logIn().then((isUserInitCompleted) {
      if (isUserInitCompleted) {
        _view.loggedIn();
      } else {
        logIn();
      }
    }).catchError((onError){
//      logIn();
      _view.error("user initialization failed");
    });
  }
}
