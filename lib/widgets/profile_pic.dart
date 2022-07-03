import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  static const double border_width = 3;
  Image image = null;
  String name;
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.grey,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.black,
    Colors.yellow,
    Colors.redAccent,
    Colors.lightBlue,
    Colors.amber,
    Colors.blueGrey,
    Colors.cyan,
    Colors.lightGreen,
    Colors.indigo,
    Colors.pink,
    Colors.pinkAccent,
    Colors.teal,
    Colors.deepPurple,
    Colors.brown,
    Colors.yellowAccent
  ];
  var rng = Random();
  int color1;
  int color2;
  ProfilePicture({this.image, this.name}) {
    color1 = rng.nextInt(colors.length);
    color2 = rng.nextInt(colors.length);
  }

  @override
  Widget build(BuildContext context) {
    return image == null ? noImage() : hasImage();
  }

  Widget hasImage() {
    return Container(
      margin: EdgeInsets.all(10),
      width: 35,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(color: colors[color2], width: border_width),
          shape: BoxShape.circle,
          image: DecorationImage(image: image.image, fit: BoxFit.cover)),
    );
  }

  Widget noImage() {
    return Container(
      margin: EdgeInsets.all(10),
      width: 35,
      height: 35,
      alignment: Alignment.center,
      child: Text(
        name.substring(0, 1).toUpperCase() + name.substring(1, 2),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      decoration: BoxDecoration(
          border: Border.all(color: colors[color2], width: border_width),
          color: colors[color1],
          shape: BoxShape.circle),
    );
  }
}
