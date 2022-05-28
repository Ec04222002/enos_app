//loading widget overlay

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:enos/constants.dart';

class Loading extends StatelessWidget {
  //const ({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLightBackgroundColor,
      child: Center(
        child: SpinKitCircle(
          color: kBrightTextColor,
          size: 60.0,
        ),
      ),
    );
  }
}
