import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enos/models/search_tile.dart';
import 'package:enos/screens/account.dart';
import 'package:enos/services/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/user.dart';
import 'package:enos/models/user_tile.dart';
import 'package:enos/screens/ticker_info.dart';
import 'package:enos/services/auth.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/stock_name_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/search_input.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import "package:enos/constants.dart";
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  bool isMainPage;
  BuildContext context;
  SearchPage({this.isMainPage = true, this.context, Key key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> recommends = [];
  List trendingRecs = [];
  String query = '';
  Timer debouncer;
  String uid;
  String market = "NASDAQ";
  String searchTitle = "Trending Stocks";
  List<String> savedSymbols = [];
  TickerTileProvider provider;
  UserModel user;
  BuildContext mainContext;
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

  Future<void> setUser() async {
    uid = mainContext.read<UserField>().userUid;
    user = await FirebaseApi.getUser(uid);
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
    print('rebuilding searchtiles');
    if (isInit) {
      mainContext = context;
      if (!widget.isMainPage) {
        mainContext = widget.context;
      }
      provider = Provider.of<TickerTileProvider>(mainContext);
      setUser();
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
                    if (market.toLowerCase() == "users") {
                      UserSearchTile tile =
                          UserSearchTile.modelToSearchTile(recommends[index]);
                      print(user.userSaved);
                      tile.isSaved = false;
                      if (user.userSaved.contains(tile.uid)) {
                        tile.isSaved = true;
                      }
                      return buildUserTile(tile, index, context);
                    }
                    //for stock search tiles
                    recommends[index].isSaved = false;
                    if (savedSymbols.contains(recommends[index].symbol)) {
                      recommends[index].isSaved = true;
                    }
                    return buildTile(index, context);
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
    ValueNotifier<bool> toggleSave = ValueNotifier(false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: kLightBackgroundColor,
        child: ListTile(
            onTap: () {
              _showUserInfo(searchTile.uid);
            },
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
            trailing: ValueListenableBuilder(
              valueListenable: toggleSave,
              builder: ((context, value, child) => IconButton(
                  onPressed: () {
                    if (searchTile.isSaved) {
                      Utils.showAlertDialog(context,
                          "Are you sure you want to remove @${searchTile.userName}?",
                          () {
                        Navigator.pop(context);
                      }, () {
                        user.userSaved
                            .removeAt(user.userSaved.indexOf(searchTile.uid));
                        searchTile.isSaved = false;
                        FirebaseApi.updateUserData(user);
                        toggleSave.value = !toggleSave.value;
                        Navigator.pop(context);
                      });

                      // user.userSaved
                      //     .removeAt(user.userSaved.indexOf(searchTile.uid));
                      // searchTile.isSaved = false;
                      // FirebaseApi.updateUserData(user);
                      // toggleSave.value = !toggleSave.value;
                    } else {
                      if (user.userSaved.length > 15) {
                        Utils.showAlertDialog(context,
                            "You have reached your limit of 15 people added.",
                            () {
                          Navigator.pop(context);
                        }, null);
                      } else {
                        user.userSaved.add(searchTile.uid);
                        searchTile.isSaved = true;
                        FirebaseApi.updateUserData(user);
                        toggleSave.value = !toggleSave.value;
                      }
                    }
                    // UserModel newUserModel = recommends[index];
                    // newUserModel.userSaved = user.userSaved;
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
            )),
      ),
    );
  }

  Widget buildTile(int index, BuildContext context) {
    ValueNotifier<bool> toggleStar = ValueNotifier(false);
    SearchTile searchTile = recommends[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: kLightBackgroundColor,
        child: ListTile(
            onTap: (() =>
                _showInfo(index, searchTile.symbol, searchTile.isSaved)),
            // tileColor: kLightBackgroundColor,
            title: Text(
              searchTile.symbol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: kBrightTextColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              searchTile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: kDisabledColor),
            ),
            trailing: ValueListenableBuilder(
              valueListenable: toggleStar,
              builder: ((context, value, child) => IconButton(
                  onPressed: () async {
                    if (!recommends[index].isSaved) {
                      if (savedSymbols.length >= 10) {
                        Utils.showAlertDialog(context,
                            "You have reached your limit of 10 tickers added.",
                            () {
                          Navigator.pop(context);
                        }, null);
                      } else {
                        searchTile.isSaved = true;

                        provider.addTicker(
                          searchTile.symbol,
                        );

                        toggleStar.value = !toggleStar.value;
                      }
                    } else if (!provider.isLoading) {
                      Utils.showAlertDialog(context,
                          "Are you sure you want to remove ${searchTile.symbol} from your watchlist?",
                          () {
                        Navigator.pop(context);
                      }, () {
                        searchTile.isSaved = false;

                        provider.removeTicker(
                            savedSymbols.indexOf(searchTile.symbol));
                        toggleStar.value = !toggleStar.value;
                        Navigator.pop(context);
                      });

                      // searchTile.isSaved = false;

                      // provider.removeTicker(
                      //     savedSymbols.indexOf(searchTile.symbol));

                      // toggleStar.value = !toggleStar.value;
                    }
                  },
                  icon: searchTile.isSaved
                      ? Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 35,
                        )
                      : Icon(
                          Icons.star_border,
                          color: kDisabledColor,
                          size: 35,
                        ))),
            )),
      ),
    );
  }

  void _showInfo(int index, String symbol, bool isSaved) async {
    TickerTileProvider provider =
        Provider.of<TickerTileProvider>(mainContext, listen: false);
    Map<String, dynamic> response = await Navigator.push(
        mainContext,
        MaterialPageRoute(
          builder: (context) => TickerInfo(
            symbol: symbol,
            uid: Provider.of<UserField>(mainContext, listen: false).userUid,
            isSaved: isSaved,
            provider: provider,
          ),
        ));
    if (!mounted) return;
    if (response['isSaved'] != isSaved) {
      setState(() {
        //recommends[index].isSaved = response['isSaved'];
        if (response['isSaved']) {
          savedSymbols.add(symbol);
          provider.addTicker(symbol);
        } else {
          savedSymbols.remove(symbol);
          provider.removeTicker(provider.symbols.indexOf(symbol));
        }
      });
    }
  }

  void _showUserInfo(String uid) async {
    // Map<String, dynamic> response = await Navigator.push(
    //     mainContext,
    //     MaterialPageRoute(
    //         builder: ((context) => AccountPage(
    //               uid: uid,
    //               provider: provider,
    //             ))));

    // setState(() {
    //   user = response['new_user'];
    // });
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return Wrap(children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.80,
              child: AccountPage(
                uid: uid,
                provider: provider,
              ),
            ),
          ]);
        });
    await setUser();
  }
}
