import 'package:enos/models/ticker_tile.dart';

class TickerInfoModel {
  final TickerTileModel tileData;
  TickerInfoModel({this.tileData});

  String shortName() {
    String fullName = tileData.companyName;
    List<String> listWords = fullName.split(" ");
    return listWords[0] + " " + listWords[1];
  }
}
