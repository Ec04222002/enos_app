import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<SearchTile> trendingRecs = [];
  String query = '';
  Timer debouncer;
  String market = "NASDAQ";
  String searchTitle = "Trending Stocks";
  void setMarket(String marketName) {
    this.market = marketName;
  }

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
      trendingRecs = recommends;
      this.searchTitle = "Recommended Stocks";
    } else {
      recommends = widget.recommends;
      trendingRecs = widget.recommends;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SearchInput(
                  text: query,
                  setMarketName: setMarket,
                  onChanged: searchStocks,
                  hintText: "Search Symbol or Name"),
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
        print("query: $query");
        if (query.isEmpty) {
          setState(() {
            this.query = query;
            this.recommends = this.trendingRecs;
            this.searchTitle = "Trending Stocks";
          });
          return;
        }
        final recs =
            await StockNameApi().getStock(query: query, market: market);

        if (!mounted) return;

        setState(() {
          this.query = query;
          this.recommends = recs;
          this.searchTitle = "Search Results";
        });
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
                        ))),
        ),
      );

  // Widget priceWidget(SearchTile data) {
  //   Color changeColor = kRedColor;
  //   String priceOp = "";
  //   //not checking leftward number expand
  //   //only checkiing rightward expand
  //   int roundedEndPriceChange = 2;
  //   int roundedEndPercentChange = 2;
  //   int roundedEndPrice = 2;
  //   double priceFontSize = 20;
  //   double tagFontSize = 14;

  //   String changeShown =
  //       data.priceChange.toStringAsFixed(roundedEndPriceChange);
  //   if (!_toggle) {
  //     changeShown =
  //         data.percentChange.toStringAsFixed(roundedEndPercentChange) + "%";
  //   }
  //   double containerWidth = 60;
  //   if (changeShown != null) {
  //     containerWidth = changeShown.length > 6 ? 70 : 60;
  //     if (changeShown[0] != "-") {
  //       changeColor = kGreenColor;
  //       priceOp = "+";
  //     }
  //   }
  //   // double containerWidth = changeShown.length > 6 ? 70 : 60;
  //   return Container(
  //     width: 100,
  //     child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.end,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           Text(
  //             "${data.price.toStringAsFixed(roundedEndPrice)}",
  //             style: TextStyle(
  //                 color: kBrightTextColor,
  //                 fontSize: priceFontSize,
  //                 fontWeight: FontWeight.w600),
  //           ),
  //           SizedBox(height: 2),
  //           GestureDetector(
  //             onTap: () => setState(() {
  //               _toggle = !_toggle;
  //             }),
  //             child: Container(
  //               padding: EdgeInsets.zero,
  //               alignment: Alignment.center,
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(3), color: changeColor),
  //               width: containerWidth,
  //               height: 17,
  //               child: Text("$priceOp${changeShown}",
  //                   textAlign: TextAlign.right,
  //                   style: TextStyle(
  //                       color: kBrightTextColor, fontSize: tagFontSize)),
  //             ),
  //           ),
  //           SizedBox(
  //             height: 2,
  //           ),
  //         ]),
  //   );
  // }
}
