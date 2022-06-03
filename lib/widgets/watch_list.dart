import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class WatchListWidget extends StatelessWidget {
  const WatchListWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TickerTileProvider>(context);
    List<TickerTileModel> tickers = provider.tickers;

    if (tickers.isEmpty) {
      //fill with default tickers
    }
    return ListView.separated(
      padding: EdgeInsets.all(12),
      separatorBuilder: (context, _) => SizedBox(height: 8),
    );
  }
}
