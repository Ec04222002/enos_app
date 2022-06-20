// ticker/chart page

import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/material.dart';
import 'package:enos/constants.dart';

class TickerInfo extends StatefulWidget {
  final TickerInfoModel info;
  const TickerInfo({this.info, Key key}) : super(key: key);

  @override
  State<TickerInfo> createState() => _TickerInfoState();
}

class _TickerInfoState extends State<TickerInfo> {
  TickerTileModel tileData;
  @override
  Widget build(BuildContext context) {
    tileData = widget.info.tileData;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: kDarkTextColor,
          icon: Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        backgroundColor: kLightBackgroundColor,
        title: Text(
          "${widget.info.shortName()} * ${tileData.price}",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: kBrightTextColor,
              fontSize: 17,
              fontWeight: FontWeight.w600),
          maxLines: 2,
        ),
      ),
    );
  }
}
