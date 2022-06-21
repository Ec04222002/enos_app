//loading widget overlay

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:enos/constants.dart';

class Loading extends StatefulWidget {
  String loadText;
  String type = "";
  Loading({this.loadText = "", this.type = "circle", Key key})
      : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.type == "circle"
                ? SpinKitCircle(
                    color: kBrightTextColor,
                    size: 60.0,
                  )
                : SpinKitThreeBounce(
                    color: kBrightTextColor,
                    size: 55.0,
                  ),
            SizedBox(
              height: 10,
            ),
            DefaultTextStyle(
              style: TextStyle(color: kDarkTextColor),
              child: Text(
                widget.loadText,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
