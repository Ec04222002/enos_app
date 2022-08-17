import 'package:enos/constants.dart';
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
  final Color commonBg;

  ColorArray(
      {Key key,
      @required this.colors,
      @required this.currentBg,
      @required this.currentBorder,
      @required this.updateFunct,
      this.bg,
      this.borderMode = false,
      this.commonBg,
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

  @override
  Widget build(BuildContext context) {
    print('rebuilding');
    print("is bordermode : ${widget.borderMode}");
    _findColorIndex();
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 5),
        width: MediaQuery.of(context).size.width * 0.8,
        // height: 100,
        color: widget.bg == null ? Colors.transparent : widget.bg,
        child: GridView.count(
          childAspectRatio: 1.7,
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 5,
          mainAxisSpacing: 5,
          // Generate 100 widgets that display their index in the List.
          children: List.generate(widget.colors.length, (index) {
            return GestureDetector(
              onTap: () {
                if (widget.borderMode) {
                  if (index != borderActiveIndex) {
                    setState(() {
                      widget.currentBorder = widget.colors[index];
                      widget.updateFunct();
                    });
                  }
                } else {
                  if (index != bgActiveIndex) {
                    setState(() {
                      widget.currentBg = widget.colors[index];
                      widget.updateFunct();
                    });
                  }
                  ;
                }

                //setState(() {});
              },
              child: CircleAvatar(
                  radius: 17,
                  backgroundColor: (() {
                    if (widget.borderMode) {
                      return widget.colors[index];
                    }
                    //background mode
                    if (index == bgActiveIndex) {
                      return kActiveColor;
                    }
                    return kDarkBackgroundColor;
                    // your code here
                  }()),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: (() {
                      if (!widget.borderMode) {
                        return widget.colors[index];
                      }

                      //border mode
                      if (index == borderActiveIndex) {
                        return kActiveColor;
                      }
                      return kLightBackgroundColor;
                    }()),
                  )),
            );
          }),
        ),
      ),
    );
  }
}
