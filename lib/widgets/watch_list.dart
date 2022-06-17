import 'package:enos/models/ticker_tile.dart';
import 'package:enos/models/watchlist.dart';
import 'package:enos/services/firebase_api.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/yahoo_api.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/ticker_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enos/constants.dart';

class WatchListWidget extends StatefulWidget {
  //const WatchListWidget({Key key}) : super(key: key);

  @override
  State<WatchListWidget> createState() => _WatchListWidgetState();
}

class _WatchListWidgetState extends State<WatchListWidget> {
  // YahooApi yahooApi = YahooApi();
  TickerTileProvider tickerProvider;
  List<TickerTileModel> tickers;

  // @override
  // void initState() {
  //   super.initState();
  //   setTickerData();
  // }

  @override
  Widget build(BuildContext context) {
    print("**in watchlist widget");
    tickerProvider = Provider.of<TickerTileProvider>(context);
    tickers = tickerProvider.tickers;
    return tickers.isEmpty
        ? Center(
            child: Text(
              "No tickers in your watchlist",
              style: TextStyle(color: kDisabledColor, fontSize: 18),
            ),
          )
        : Theme(
            data: ThemeData(canvasColor: Colors.transparent),
            child: ReorderableListView.builder(
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                return TickerTile(
                    key: ValueKey(index), tickerTileData: tickers[index]);
              },
              itemCount: tickers.length,
              onReorder: _onReorder,
            ),
          );
  }

  void _onReorder(int startIndex, int endIndex) {
    // print("StartIndex: $startIndex");
    // print("EndIndex: $endIndex");
    setState(() {
      tickerProvider.moveTicker(startIndex, endIndex);
      FirebaseApi.updateWatchList(Watchlist(
          watchlistUid: tickerProvider.watchListUid,
          items: tickerProvider.symbols,
          updatedLast: DateTime.now(),
          isPublic: tickerProvider.isPublic));
    });
  }
}
