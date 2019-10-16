import 'package:flutter/material.dart';

const APP_NAME = "Tess TODO";

const PAGE_HOME = "/";
const PAGE_LOGIN = "/page_login";
const PAGE_ADD = "/page_add";
const PAGE_HISTORY = "/page_history";
const PAGE_SETTINGS = "/page_settings";
const PAGE_COMMON = "/page_common";

const FIRE_BASE_ROUTE_PRIVATE_TODO = "private_todo";
const FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS = "tasks";
const FIRE_BASE_ROUTE_PRIVATE_TODO_COMMON_TASKS = "common_tasks";
const FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_NAME = "name";
const FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_COLOR = "color";
const FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_DATE = "date";
const FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_COMPLETED = "isCompleted";
const FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_IS_OPEN = "isOpen";
const FIRE_BASE_ROUTE_PRIVATE_TODO_TASKS_ITEMS = "tasks_items";

const FIRE_BASE_ROUTE_SHARED_TODO = "shared_todo";

const LAUNCH_TYPE_APP_START = "appStart";
const LAUNCH_TYPE_ADD_TODO = "addTodo";
const LAUNCH_TYPE_EMPTY_TODO_ID = "emptyTodoId";

const PREF_USER_AUTH_KEY = "pref_user_auth_key";
const PREF_USER_SETTINGS_USE_HORIZONTAL_FAB = "pref_user_settings_use_horizontal_fab";

const PADDING_ADD_TODO_GENERAL = EdgeInsets.only(left: 20.0, right: 20.0);
const PADDING_ADD_TODO_COLOR_PICKER = EdgeInsets.all(6.0);


const TODO_CARD_NAME_MAX_LENGTH = 25;
const TODO_INNER_NAME_MAX_LENGTH = 40;
const TODO_NAME_INPUT_TEXT_SIZE = 18.0;

const COLOR_PICKER_COLORS = [
  Colors.lightGreen,
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.green,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
  Colors.lime,
  Colors.purple,
  Colors.cyan,
  Colors.indigo,
  Colors.amber,
  Colors.lightBlue,
  Colors.grey,
  Colors.deepOrange,
  Colors.teal,
  Colors.brown,
  Colors.blueGrey,
];

class AppColorsMainTheme {
  static const MAIN_APP_THEME_COLOR = Colors.white;
  static const MAIN_BUTTON_COLOR = Color(0xFF01579B);
  static const MAIN_BACKGROUND_COLOR = Colors.white;
  static const MAIN_TEXT_COLOR = Colors.black;
}

class AppSettingsOther {}
