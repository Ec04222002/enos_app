import 'dart:async';
import 'dart:convert';

import 'package:enos/models/search_tile.dart';
import 'package:enos/services/stock_name_api.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/search_input.dart';
import "package:flutter/material.dart";
import "package:enos/constants.dart";

class SearchList extends StatefulWidget {
  List<SearchTile> recommends = [];
  SearchList({this.recommends, Key key}) : super(key: key);

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  List<SearchTile> recommends = [];
  String query = '';
  Timer debouncer;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    if (widget.recommends.isEmpty) {
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
    } else {
      recommends = widget.recommends;
    }
    //init();
  }

  @override
  void dispose() {
    debouncer.cancel();
    super.dispose();
  }

  //cancels recent timer if typed fase
  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (debouncer != null) {
      debouncer.cancel();
    }

    debouncer = Timer(duration, callback);
  }

  //get init recommendation
  // Future init() async {
  //   final List<SearchTile> response =
  //       await YahooApi().getRecommendedStockList();
  //   setState(() {
  //     this.recommends = response;
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              SearchInput(
                  text: query,
                  onChanged: searchStocks,
                  hintText: "Search Symbol or Name"),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Trending Stocks",
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

                    return buildTile(stockTileModel, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future searchStocks(String query) async => debounce((() async {
        final recs = await StockNameApi().getStock(query: query);
      }));

  Widget buildTile(SearchTile stockTileModel, int index) => ClipRRect(
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
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              stockTileModel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: kDisabledColor),
            ),
            trailing: IconButton(
                onPressed: () => setState(() {
                      recommends[index].isSaved = !recommends[index].isSaved;
                    }),
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
                      )),
          ),
        ),
      );
}
