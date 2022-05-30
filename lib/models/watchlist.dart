import 'package:enos/services/util.dart';

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

  static Watchlist fromJson(Map<String, dynamic> json) => Watchlist(
      watchlistUid: json['watchlist_uid'],
      items: json['items'],
      updatedLast: toDateTime(json['updated_last']),
      isPublic: json['is_public']);

  Map<String, dynamic> toJson() => {
        'watchlist_uid': watchlistUid,
        'items': items,
        'updated_last': fromDateTimeToJson(updatedLast),
        'is_public': isPublic,
      };
}
