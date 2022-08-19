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
  final Color commonBg;

  //selections are for images
  int crossCount;
  final List<IconData> iconList;
  final List<String> label;
  bool dualMode;
  final List<dynamic> onclicks;

  ColorArray(
      {Key key,
      @required this.colors,
      @required this.currentBg,
      @required this.currentBorder,
      @required this.updateFunct,
      @required this.crossCount,
      this.iconList,
      this.onclicks,
      this.label,
      this.bg,
      this.borderMode = false,
      this.dualMode = false,
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

  // Widget addLabelWrap(Widget child, int index) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         flex: 2,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [child, Text(widget.label[index])],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    _findColorIndex();
    return Container(
      padding: EdgeInsets.only(top: 8),
      height: MediaQuery.of(context).size.height * 0.31,
      width: MediaQuery.of(context).size.width * 0.8,
      // height: 100,
      color: widget.bg == null ? Colors.transparent : widget.bg,
      child: GridView.count(
        childAspectRatio: widget.dualMode ? 1.4 : 1.6,
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: widget.crossCount,
        mainAxisSpacing: 5,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(widget.colors.length, (index) {
          Widget btn = GestureDetector(
            onTap: () {
              if (widget.onclicks != null && widget.onclicks.isNotEmpty) {
                widget.onclicks[index]();
                return;
              }

              //for borders and background
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
              radius: widget.crossCount < 4 ? 37 : 17,
              backgroundColor: (() {
                if (widget.borderMode || widget.dualMode) {
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
                child: widget.iconList != null && widget.iconList.isNotEmpty
                    ? Icon(
                        widget.iconList[index],
                        size: 48,
                      )
                    : Container(
                        height: 0,
                      ),
                radius: widget.crossCount < 4 ? 37 : 15,
                backgroundColor: (() {
                  if (!widget.borderMode || widget.dualMode) {
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

          // if (widget.dualMode) {
          //   Widget sizedBtn = Container(width: 500, child: btn);
          //   return addLabelWrap(btn, index);
          // }
          return btn;
        }),
      ),
    );
  }
}
