import 'package:flutter_tess_todo/di/home_page_injections.dart';
import 'package:flutter_tess_todo/repository/user_repository.dart';

abstract class SettingsContract {
  void loggedOut();
  void error(String error);
}

class SettingsPresenter {
  SettingsContract _view;

  UserRepository _userRepository;

  SettingsPresenter(this._view) {
    _userRepository = new Injector().userRepositoryState;
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
