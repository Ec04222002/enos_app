import 'package:enos/constants.dart';
import 'package:flutter/material.dart';

class SliderWidget extends StatelessWidget {
  final double value, max, min;
  const SliderWidget({this.value, this.max, this.min, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.zero,
        width: 135,
        child: Stack(children: [
          Row(children: [
            Expanded(
                child: Text(
              min.toString(),
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12, color: kBrightTextColor),
            )),
            Expanded(
                child: Text(
              max.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: kBrightTextColor),
            ))
          ]),
          SliderTheme(
            data: SliderThemeData(
                trackHeight: 2,
                trackShape: RectangularSliderTrackShape(),
                activeTrackColor: kDisabledColor,
                inactiveTrackColor: kDisabledColor,
                overlappingShapeStrokeColor: Colors.transparent,
                overlayColor: Colors.transparent,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5)),
            child: Slider(
                thumbColor: kBrightTextColor,
                value: value,
                min: min,
                max: max,
                mouseCursor: MouseCursor.uncontrolled,
                onChanged: (double value) {}),
          ),
        ]));
  }
}
