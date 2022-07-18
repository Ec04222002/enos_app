import 'package:enos/constants.dart';
import 'package:flutter/material.dart';

class DatesBar extends StatefulWidget {
  final Function onTap;

  const DatesBar({
    this.onTap,
    Key key,
  }) : super(key: key);

  @override
  State<DatesBar> createState() => _DatesBarState();
}

class _DatesBarState extends State<DatesBar> with TickerProviderStateMixin {
  int _tabIndex = 0;
  int _previousIndex = 0;
  var tab;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tab = TabController(initialIndex: 0, length: 7, vsync: this);

    tab.addListener(() => setState(() {
          tab.index = _tabIndex;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 10),
      height: 30,
      // decoration: BoxDecoration(
      //     color: kLightBackgroundColor,
      //     border: Border.all(color: Colors.transparent),
      //     borderRadius: BorderRadius.circular(10)),
      width: MediaQuery.of(context).size.width * 0.85,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          color: kLightBackgroundColor,
          child: DefaultTabController(
            length: 7,
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
                controller: tab,
                onTap: (value) {
                  var response = widget.onTap(value);
                  if (response == null) {
                    _tabIndex = _previousIndex;
                  } else {
                    _tabIndex = value;
                    _previousIndex = _tabIndex;
                  }
                },
                isScrollable: true,
                indicatorPadding: EdgeInsets.zero,
                //labelPadding: EdgeInsets.symmetric(horizontal: 16.5),
                indicator: BoxDecoration(
                  color: kActiveColor,
                ),

                unselectedLabelColor: kDisabledColor,
                labelColor: kBrightTextColor,

                labelStyle: TextStyle(fontSize: 13),
                unselectedLabelStyle: TextStyle(fontSize: 13),
                tabs: [
                  Tab(
                    text: '1D',
                  ),
                  Tab(
                    text: '5D',
                  ),
                  Tab(
                    text: '1M',
                  ),
                  Tab(
                    text: '6M',
                  ),
                  Tab(
                    text: '1Y',
                  ),
                  Tab(
                    text: '5Y',
                  ),
                  Tab(
                    text: 'Max',
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
