import 'package:enos/constants.dart';
import 'package:flutter/material.dart';

class SavedUsers extends StatelessWidget {
  const SavedUsers({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 22,
        onPressed: openSavedUsersPage,
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
          color: kDarkTextColor,
        ));
  }

  static openSavedUsersPage() {}
}
