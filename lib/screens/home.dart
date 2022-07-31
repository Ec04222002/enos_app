//watchlist page
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/constants.dart';
import 'package:enos/models/search_tile.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/services/util.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/screens/search.dart';
import 'package:enos/widgets/ticker_tile.dart';
import 'package:enos/widgets/watch_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TickerTileProvider provider;
  double initBtnOpacity = 0.75, btnOpacity = 0.75;
  Utils util = Utils();
  @override
  Widget build(BuildContext context) {
    provider = Provider.of<TickerTileProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        centerTitle: true,
        title: Image.asset('assets/logo2.png', width: 130),
        actions: [
          IconButton(
              iconSize: 30,
              color: kDarkTextColor.withOpacity(0.9),
              onPressed: () {
                showSearch(context);
              },
              tooltip: "Add ticker to watchlist",
              icon: Icon(Icons.add_circle_outline))
        ],
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          util.showSnackBar(context, "Streaming Data ", true);
          //print("in long press");
          setState(() {
            btnOpacity = 0.3;
            provider.isLive = true;
          });
        },
        onLongPressEnd: (_) {
          util.removeSnackBar();
          //print("end press");
          setState(() {
            btnOpacity = initBtnOpacity;
            provider.isLive = false;
          });
        },
        onLongPressCancel: () {
          //print("cancel press");
          setState(() {
            btnOpacity = initBtnOpacity;
            provider.isLive = false;
          });
        },
        onTap: () {
          //print("tap");
          setState(() {
            btnOpacity = initBtnOpacity;
            provider.isLive = false;
          });
        },
        onTapCancel: () {
          //print("tap cancel");
          setState(() {
            btnOpacity = initBtnOpacity;
            provider.isLive = false;
          });
        },
        onTapUp: (_) {
          //print('tap up');
          setState(() {
            btnOpacity = initBtnOpacity;
            provider.isLive = false;
          });
        },
        onDoubleTap: () {
          setState(() {
            provider.isLive = false;
          });
        },
        onDoubleTapCancel: () {
          setState(() {
            btnOpacity = initBtnOpacity;
            provider.isLive = false;
          });
          //print("double tap end");
        },
        child: FloatingActionButton(
          child: Icon(
            Icons.keyboard_double_arrow_up_outlined,
            size: 50,
            color: kDarkTextColor,
          ),
          elevation: 5,
          highlightElevation: 0,
          disabledElevation: 0,
          backgroundColor:
              Utils.lighten(kLightBackgroundColor).withOpacity(btnOpacity),
        ),
      ),
      //
      // ?? streambuilder at child property
      body: WatchListWidget(),
    );
  }

  void showSearch(BuildContext buildContext) {
    print('buildContext: $buildContext');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(
            isMainPage: false,
            context: buildContext,
          ),
        ));
  }
}
