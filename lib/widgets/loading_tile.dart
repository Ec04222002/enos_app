import 'package:enos/constants.dart';
import 'package:enos/widgets/loading.dart';
import 'package:flutter/material.dart';

class LoadingTiles extends StatelessWidget {
  const LoadingTiles({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      color: kLightBackgroundColor,
      child: ListTile(
        onTap: null,
        onLongPress: null,
        visualDensity: VisualDensity(horizontal: 0, vertical: 2.6),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        title: Loading(
          type: "dot",
          size: 30,
        ),
      ),
    );
  }
}
