//watchlist page
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/constants.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/ticker_tile.dart';
import 'package:enos/widgets/watch_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  // final List<TickerTileModel> data;
  // const HomePage({this.data, Key key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print('in home');
    //for init
    // String watchListUid;
    // final user = context.watch<UserField>();
    // if (user != null) {
    //   watchListUid = user.userUid;
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        centerTitle: true,
        title: Image.asset('assets/logo2.png', width: 133),
        actions: [
          IconButton(
              iconSize: 30,
              color: kDarkTextColor.withOpacity(0.9),
              onPressed: () {},
              tooltip: "Add ticker to watchlist",
              icon: Icon(Icons.add_circle_outline))
        ],
      ),
      //
      // ?? streambuilder at child property
      body: WatchListWidget(),
    );
  }
}
