import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/widgets/loading.dart';
import 'package:enos/widgets/ticker_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enos/constants.dart';

class WatchListWidget extends StatelessWidget {
  const WatchListWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<TickerTileProvider>(context);
    // List<TickerTileModel> tickers = provider.tickers ?? [];
    List<TickerTileModel> tickers =
        Provider.of<List<TickerTileModel>>(context) ?? [];
    return tickers.isEmpty
        ? Center(
            child: Text(
              "No tickers in your watchlist",
              style: TextStyle(color: kDisabledColor, fontSize: 18),
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.all(12),
            separatorBuilder: (context, _) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ticker = tickers[index];
              print(ticker.tickerName);
              return Text(ticker.tickerName);
              //return TickerTile(ticker: ticker);
            },
            itemCount: tickers.length,
          );
  }
}
