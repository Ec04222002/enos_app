import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EmailNotify extends StatelessWidget {
  const EmailNotify({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 20, width: 40, child: Slider(value: 100, onChanged: (_) {}));
  }
}
