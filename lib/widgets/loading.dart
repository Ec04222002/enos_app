//loading widget overlay

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:enos/constants.dart';

class Loading extends StatelessWidget {
  final String loadText;
  const Loading({this.loadText = "", Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCircle(
              color: kBrightTextColor,
              size: 60.0,
            ),
            SizedBox(
              height: 10,
            ),
            DefaultTextStyle(
              style: TextStyle(color: kDarkTextColor),
              child: Text(
                loadText,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
