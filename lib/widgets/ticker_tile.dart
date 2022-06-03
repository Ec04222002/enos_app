import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/cupertino.dart';

class TickerTile extends StatefulWidget {
  final TickerTileModel ticker;
  const TickerTile({@required this.ticker, Key key}) : super(key: key);

  @override
  State<TickerTile> createState() => _TickerTileState();
}

class _TickerTileState extends State<TickerTile> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
