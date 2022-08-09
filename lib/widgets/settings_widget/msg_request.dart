import 'package:enos/constants.dart';
import 'package:flutter/material.dart';

class MessageRequest extends StatelessWidget {
  const MessageRequest({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 22,
        onPressed: () {},
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
          color: kDarkTextColor,
        ));
  }
}