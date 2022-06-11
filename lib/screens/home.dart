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
  //const HomePage({Key key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print('in home');
    //for init
    String watchListUid;
    UserModel user = Provider.of<AuthService>(context).user;
    if (user != null) {
      watchListUid = user.userUid;
    }
    print(watchListUid);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        centerTitle: true,
        title: Image.asset('assets/logo2.png', width: 133),
        leading: IconButton(
          iconSize: 33,
          color: kDarkTextColor.withOpacity(0.9),
          onPressed: () {
            print(watchListUid);
          },
          tooltip: "Edit watchlist",
          icon: Icon(Icons.edit_note),
        ),
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
      body: StreamBuilder<List<TickerTileModel>>(
        stream: FirebaseApi.watchlistTickers(watchListUid),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Loading();
            default:
              if (snapshot.hasError || !snapshot.hasData) {
                print('error');
                return Center(
                  child: Text("Something Went Wrong. Please try again later"),
                );
              } else {
                //print(snapshot.data);
                final tickers = snapshot.data;
                print("At home: tickers is: ${tickers}");
                final provider = Provider.of<TickerTileProvider>(context);
                provider.setTickers(tickers: tickers);
                return WatchListWidget();
              }
          }
        },
      ),
    );
  }
}
