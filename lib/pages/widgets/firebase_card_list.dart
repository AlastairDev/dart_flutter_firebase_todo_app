import 'package:flutter/material.dart';

enum CardType { TYPE_MAIN_PAGE, TYPE_COMMON_PAGE, TYPE_HISTORY_PAGE }

class FirebaseCardList extends StatefulWidget {
  FirebaseCardList({
    Key key,
    @required CardType type,
  });

  @override
  _FirebaseCardListState createState() => _FirebaseCardListState();
}

class _FirebaseCardListState extends State<FirebaseCardList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}
