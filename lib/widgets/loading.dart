//loading widget overlay

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:enos/constants.dart';

class Loading extends StatefulWidget {
  String loadText;
  String type = "";
  double size;
  Color bgColor;
  Loading(
      {this.loadText = "", this.type = "circle", this.size, this.bgColor, key})
      : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.bgColor == null ? kDarkBackgroundColor : widget.bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.type == "circle"
                ? SpinKitCircle(
                    color: kBrightTextColor,
                    size: widget.size == null ? 65.0 : widget.size,
                  )
                : SpinKitThreeBounce(
                    color: kBrightTextColor,
                    size: widget.size == null ? 50 : widget.size,
                  ),
            widget.loadText.isEmpty
                ? Container(
                    height: 0,
                  )
                : SizedBox(
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
