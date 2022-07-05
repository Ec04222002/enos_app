import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/search_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/user_tile.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/stock_name_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/search_input.dart';
import "package:flutter/material.dart";
import "package:enos/constants.dart";
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  BuildContext context;
  bool isMainPage;
  SearchPage({this.isMainPage = true, this.context, Key key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> recommends = [];
  List trendingRecs = [];
  String query = '';
  Timer debouncer;
  String market = "NASDAQ";
  String searchTitle = "Trending Stocks";
  List<String> savedSymbols = [];
  TickerTileProvider provider;
  UserModel user;

  bool isInit = true;
  //BuildContext context;
  void setMarket(String marketName) {
    this.market = marketName;
  }

  void checkRecommends() {
    if (recommends.isEmpty) {
      recommends = [
        SearchTile(
          symbol: "^SPX",
          name: "S&P 500",
        ),
        SearchTile(
          symbol: "^DJI",
          name: "Dow Jones Industrial Average",
        ),
        SearchTile(
          symbol: "TSLA",
          name: "Tesla, Inc.",
        ),
        SearchTile(
          symbol: "AMZN",
          name: "Amazon.com, Inc.",
        ),
        SearchTile(
          symbol: "NFLX",
          name: "Netflix, Inc.",
        ),
        SearchTile(
          symbol: "BTC-USD",
          name: "Bitcoin USD",
        ),
      ];
      trendingRecs = recommends;
      this.searchTitle = "Recommended Stocks";
    } else {
      //recommends = recommends;
      trendingRecs = recommends;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isMainPage) {
      provider = Provider.of<TickerTileProvider>(widget.context);
      savedSymbols = provider.symbols;
      user = widget.context.read<AuthService>().userModel;
      recommends = provider.recs;
      //check if recommends is empty => put default if so
      checkRecommends();
    }
  }

  @override
  void dispose() {
    if (debouncer != null) {
      debouncer.cancel();
    }

    super.dispose();
  }

  //cancels recent timer if typed fase
  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 800),
  }) {
    if (debouncer != null) {
      debouncer.cancel();
    }

    debouncer = Timer(duration, callback);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMainPage && isInit) {
      provider = Provider.of<TickerTileProvider>(context);
      user = context.read<AuthService>().userModel;
      savedSymbols = provider.symbols;
      recommends = provider.recs;
      //check if recommends is empty => put default if so
      checkRecommends();
      //context = context;
      isInit = false;
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SearchInput(
                  text: query,
                  setMarketName: setMarket,
                  onChanged: searchTiles,
                  hintText: (widget.isMainPage)
                      ? "Search Stocks or Users"
                      : "Search Symbol or Name"),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Text(
                    searchTitle,
                    style: TextStyle(
                        color: kDisabledColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, _) => SizedBox(
                    height: 8,
                  ),
                  itemCount: recommends.length,
                  itemBuilder: (context, index) {
                    final stockTileModel = recommends[index];

                    if (market.toLowerCase() == "users") {
                      UserSearchTile tile =
                          UserSearchTile.modelToSearchTile(stockTileModel);

                      if (user.userSaved.contains(tile.uid)) {
                        tile.isSaved = true;
                      }
                      return buildUserTile(tile, index, context);
                    }
                    //for stock search tiles
                    if (savedSymbols.contains(stockTileModel.symbol)) {
                      stockTileModel.isSaved = true;
                    }
                    return buildTile(stockTileModel, index, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future searchTiles(String query) async => debounce((() async {
        if (query.isEmpty) {
          if (market.toLowerCase() == "users") {
            setState(() {
              this.query = query;
              this.recommends = [];
            });
            return;
          }

          //for market
          setState(() {
            this.query = query;
            this.recommends = this.trendingRecs;
            this.searchTitle = "Trending Stocks";
          });
          return;
        }
        var recs;
        if (market.toLowerCase() == "users") {
          recs = await FirebaseApi.getAllUser(searchQuery: query);
          print("recs: ${recs}");
        } else {
          recs = await StockNameApi().getStock(query: query, market: market);
        }

        if (!mounted) return;

        setState(() {
          this.query = query;
          this.recommends = recs;
          this.searchTitle = "Search Results";
        });
      }));

  Widget buildUserTile(
      UserSearchTile searchTile, int index, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: kLightBackgroundColor,
        child: ListTile(
            leading: searchTile.leadWidget,
            title: Text(
              "@" + searchTile.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: kBrightTextColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            trailing: IconButton(
                onPressed: () {
                  if (searchTile.isSaved) {
                    Utils.showAlertDialog(context,
                        "Are you sure you want to remove @${searchTile.userName}?",
                        () {
                      Navigator.pop(context);
                    }, () {
                      setState(() {
                        user.userSaved
                            .removeAt(user.userSaved.indexOf(searchTile.uid));
                      });
                      Navigator.pop(context);
                    });
                  } else {
                    if (user.userSaved.length > 15) {
                      Utils.showAlertDialog(context,
                          "You have reached your limit of 15 people added.",
                          () {
                        Navigator.pop(context);
                      }, null);
                    } else {
                      setState(() {
                        user.userSaved.add(searchTile.uid);
                      });
                    }
                  }
                  UserModel newUserModel = recommends[index];
                  newUserModel.userSaved = user.userSaved;
                  FirebaseApi.updateUserData(newUserModel);
                },
                icon: searchTile.isSaved
                    ? Icon(
                        Icons.bookmark_outlined,
                        color: kDisabledColor,
                        size: 35,
                      )
                    : Icon(
                        Icons.bookmark_border,
                        color: kDisabledColor,
                        size: 35,
                      ))),
      ),
    );
  }

  Widget buildTile(
          SearchTile stockTileModel, int index, BuildContext context) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          color: kLightBackgroundColor,
          child: ListTile(
              // tileColor: kLightBackgroundColor,
              title: Text(
                stockTileModel.symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: kBrightTextColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                stockTileModel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: kDisabledColor),
              ),
              trailing: IconButton(
                  onPressed: () async {
                    if (!recommends[index].isSaved) {
                      if (savedSymbols.length >= 10) {
                        Utils.showAlertDialog(context,
                            "You have reached your limit of 10 tickers added.",
                            () {
                          Navigator.pop(context);
                        }, null);
                      } else {
                        setState(() {
                          recommends[index].isSaved = true;
                        });
                        await provider.addTicker(stockTileModel.symbol);
                      }
                    } else {
                      Utils.showAlertDialog(context,
                          "Are you sure you want to remove ${stockTileModel.symbol} from your watchlist?",
                          () {
                        Navigator.pop(context);
                      }, () async {
                        setState(() {
                          recommends[index].isSaved = false;
                        });
                        await provider.removeTicker(
                            savedSymbols.indexOf(stockTileModel.symbol));
                        Navigator.pop(context);
                      });
                    }
                  },
                  icon: stockTileModel.isSaved
                      ? Icon(
                          Icons.star,
                          color: Colors.yellow[400],
                          size: 35,
                        )
                      : Icon(
                          Icons.star_border,
                          color: kDisabledColor,
                          size: 35,
                        ))),
        ),
      );
}
