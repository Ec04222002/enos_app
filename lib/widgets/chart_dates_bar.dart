import 'package:enos/constants.dart';
import 'package:flutter/material.dart';

class DatesBar extends StatelessWidget {
  final Function onTap;
  const DatesBar({
    this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kLightBackgroundColor,
      child: Container(
        //padding: EdgeInsets.symmetric(vertical: 10),
        height: 35,
        width: MediaQuery.of(context).size.width,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: DefaultTabController(
            length: 8,
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
                onTap: onTap,
                isScrollable: true,
                indicatorPadding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 16.5),
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
                    text: '2Y',
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
