import 'package:enos/constants.dart';
import 'package:enos/services/util.dart';
import 'package:flutter/material.dart';

class ColorArray extends StatefulWidget {
  final List<Color> colors;
  Function updateFunct;
  final bool isCircle;
  Color currentBg;
  final bg;

  //selections are border
  Color currentBorder;
  bool borderMode;

  List<Map<String, dynamic>> additionalBtns;
  int crossCount;

  ColorArray(
      {Key key,
      @required this.colors,
      @required this.currentBg,
      @required this.currentBorder,
      @required this.updateFunct,
      @required this.crossCount,
      this.additionalBtns,
      this.bg,
      this.borderMode = false,
      this.isCircle = true})
      : super(key: key);

  @override
  State<ColorArray> createState() => _ColorArrayState();
}

class _ColorArrayState extends State<ColorArray> {
  int bgActiveIndex;
  int borderActiveIndex;

  //finding selected color index
  void _findColorIndex() {
    for (int i = 0; i < widget.colors.length; ++i) {
      if (widget.colors[i] == widget.currentBg ||
          widget.colors[i].value == widget.currentBg.value) {
        bgActiveIndex = i;
      }
      if (widget.colors[i] == widget.currentBorder ||
          widget.colors[i].value == widget.currentBorder.value) {
        borderActiveIndex = i;
      }
    }
  }

  // @override
  // void initState() {
  //   _findColorIndex();
  //   super.initState();
  // }
  // Widget addLabelWrap(Widget child, int index) {
  //   return Column(
  //     children: [child, Text(widget.label[index])],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    _findColorIndex();
    return Container(
      padding: EdgeInsets.only(top: 5),
      height: MediaQuery.of(context).size.height * 0.30,
      width: MediaQuery.of(context).size.width * 0.8,
      // height: 100,
      color: widget.bg == null ? Colors.transparent : widget.bg,
      child: GridView.count(
        childAspectRatio: 1.6,
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: widget.crossCount,
        mainAxisSpacing: 5,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(
            widget.colors.length + widget.additionalBtns.length, (index) {
          return GestureDetector(
            onTap: () async {
              if (widget.borderMode) {
                if (index != borderActiveIndex) {
                  setState(() {
                    widget.currentBorder = widget.colors[index];
                    //borderActiveIndex = index;
                    widget.updateFunct();
                  });
                }
              } else {
                if (index >= widget.colors.length) {
                  dynamic response =
                      await widget.additionalBtns[index - widget.colors.length]
                          ['onclick']();
                  if (response != null) {
                    setState(() {
                      //bgActiveIndex = index;
                    });
                  }
                  return;
                }
                if (index != bgActiveIndex) {
                  print("clicked on just color");
                  setState(() {
                    widget.currentBg = widget.colors[index];
                    //bgActiveIndex = index;
                    widget.updateFunct();
                  });
                }
                ;
              }

              //setState(() {});
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: (() {
                if (widget.borderMode) {
                  return widget.colors[index];
                }
                //background mode
                if (index == bgActiveIndex) {
                  return kActiveColor;
                }
                return kDarkBackgroundColor;
              }()),
              child: CircleAvatar(
                child: (() {
                  if (index >= widget.colors.length) {
                    return Icon(
                      widget.additionalBtns[index - widget.colors.length]
                          ['icon'],
                      size: 20,
                    );
                  }

                  return Container(
                    height: 0,
                  );
                }()),
                radius: 17,
                backgroundColor: (() {
                  //addtional btn background
                  if (index >= widget.colors.length) {
                    return Utils.lighten(kLightBackgroundColor);
                  }

                  if (!widget.borderMode) {
                    return widget.colors[index];
                  }

                  //border mode
                  if (index == borderActiveIndex) {
                    return kActiveColor;
                  }
                  return kLightBackgroundColor;
                }()),
              ),
            ),
          );
        }),
      ),
    );
  }
}
