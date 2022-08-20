import 'dart:math';

import 'package:enos/services/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  double border_width = 2;
  Image image = null;
  String name;
  double width, height, fontSize;
  Color color1;
  Color color2;
  static List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.grey,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.black,
    Colors.red[300],
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
    Colors.deepOrange
  ];
  static String getRandomColor() {
    List<Color> colors = ProfilePicture.colors;

    return Utils.colorToHexString(colors[Random().nextInt(colors.length)]);
  }

  ProfilePicture(
      {this.image,
      this.name,
      this.color1,
      this.color2,
      this.width = 37,
      this.height = 37,
      this.fontSize = 16}) {
    if (color1 == null) color1 = Utils.stringToColor(getRandomColor());
    if (color2 == null) color2 = Utils.stringToColor(getRandomColor());
  }

  @override
  Widget build(BuildContext context) {
    return image == null ? noImage() : hasImage();
  }

  Widget hasImage() {
    return Container(
      margin: EdgeInsets.all(5),
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(color: color2, width: border_width),
          shape: BoxShape.circle,
          image: DecorationImage(image: image.image, fit: BoxFit.cover)),
    );
  }

  Widget noImage() {
    return Container(
      margin: EdgeInsets.all(5),
      width: width,
      height: height,
      alignment: Alignment.center,
      child: name == "" || name == null
          ? SizedBox.shrink()
          : Text(
              name.substring(0, 1).toUpperCase() +
                  (name.length > 1 ? name.substring(1, 2) : ""),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize),
            ),
      decoration: BoxDecoration(
          border: Border.all(color: color2, width: border_width),
          color: color1,
          shape: BoxShape.circle),
    );
  }
}
