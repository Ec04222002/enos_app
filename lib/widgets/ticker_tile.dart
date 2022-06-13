import 'package:enos/models/ticker_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:enos/constants.dart';

class TickerTile extends StatelessWidget {
  final ticker;
  const TickerTile({this.ticker, Key key}) : super(key: key);
  //create tile from yahoo api
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: const [
              SlidableAction(
                foregroundColor: kRedColor,
                icon: Icons.remove_circle,
                onPressed: deleteTicker,
              )
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                  foregroundColor: kDisabledColor,
                  icon: Icons.menu,
                  onPressed: moveTicker)
            ],
          ),
          key: Key(ticker.tickerName),
        ));
  }
}

void deleteTicker(BuildContext context) {}
void moveTicker(BuildContext context) {}
