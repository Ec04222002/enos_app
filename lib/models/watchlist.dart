import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/util.dart';
import 'package:enos/widgets/ticker_tile.dart';

class WatchlistField {
  static const createdTime = 'createdTime';
}

class Watchlist {
  final String watchlistUid;
  final List<String> items;
  final DateTime updatedLast;
  final bool isPublic;

  Watchlist({
    this.watchlistUid,
    this.items,
    this.updatedLast,
    this.isPublic = false,
  });

  static Watchlist fromJson(Map<String, dynamic> json) {
    // List tickerList = [];
    // List jsonTickerList = json["items"];

    // for (var i = 0; i < jsonTickerList.length; ++i) {
    //   tickerList.add(jsonTickerList[i].fromJson());
    // }
    return Watchlist(
        watchlistUid: json['watchlist_uid'],
        items: json['items'],
        updatedLast: Utils.toDateTime(json['updated_last']),
        isPublic: json['is_public']);
  }

  Map<String, dynamic> toJson() {
    // List jsonTickerList = [];
    // for (var i = 0; i < items.length; ++i) {
    //   jsonTickerList.add(items[i].toJson());
    // }
    return {
      'watchlist_uid': watchlistUid,
      'items': items,
      'updated_last': Utils.fromDateTimeToJson(updatedLast),
      'is_public': isPublic
    };
  }
}
