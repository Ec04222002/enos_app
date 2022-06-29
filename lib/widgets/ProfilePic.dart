import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {

  Image image = null;
  String name;
  List<Color> colors = [Colors.red,Colors.blue,Colors.grey, Colors.green, Colors.orange,Colors.purple,Colors.black,Colors.yellow];
  var rng = Random();
  int pos;
  ProfilePicture({this.image,this.name}) {
    pos = rng.nextInt(colors.length);
  }

  @override
  Widget build(BuildContext context) {
    return image==null? noImage():hasImage();
  }


  Widget hasImage() {
    return Container(
      margin: EdgeInsets.all(10),
      width: 35,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: image.image,
            fit: BoxFit.cover
        )
      ),
    );
  }

  Widget noImage() {
    return Container(
      margin: EdgeInsets.all(10),
      width: 35,
      height: 35,
      alignment: Alignment.center,
      child: Text(
        name.substring(0,2),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      ),
      decoration: BoxDecoration(
        color: colors[pos],
        shape: BoxShape.circle
      ),
    );
  }
}
