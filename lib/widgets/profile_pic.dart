import 'dart:math';

import 'package:enos/services/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  double border_width = 1;
  Image image = null;
  String name;

  Color color1;
  Color color2;
  static String getRandomColor() {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.grey,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.black,
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
    ];
    return Utils.colorToHexString(colors[Random().nextInt(colors.length)]);
  }

  ProfilePicture({this.image, this.name, this.color1, this.color2});

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
          border: Border.all(color: color2, width: border_width),
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
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      decoration: BoxDecoration(
          border: Border.all(color: color2, width: border_width),
          color: color1,
          shape: BoxShape.circle),
    );
  }
}
