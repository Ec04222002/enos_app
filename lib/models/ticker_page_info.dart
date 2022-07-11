import 'package:enos/models/ticker_tile.dart';

class TickerPageModel {
  String symbol;
  String companyName;
  String postPrice;
  String marketPrice;
  String postMarketPrice;
  String percentChange;
  String postPercentChange;
  String priceChange;
  String postPriceChange;
  String shortName;
  double openPrice;
  List chartDataY;
  List chartDataX;
  bool isCrypto;
  bool isPostMarket;
  bool isSaved;
  bool isLive;
  int closeTime;
  int postCloseTime;
  TickerPageModel(
      {this.symbol,
      this.companyName,
      this.shortName,
      this.marketPrice,
      this.postMarketPrice,
      this.percentChange,
      this.isPostMarket = false,
      this.postPercentChange,
      this.priceChange,
      this.postPriceChange,
      this.openPrice,
      this.chartDataX,
      this.chartDataY,
      this.isCrypto = false,
      this.isLive = true,
      this.isSaved = false,
      this.closeTime,
      this.postCloseTime});

  static TickerPageModel fromTickerTileModel(
      {TickerTileModel data, dynamic compleData}) {
    TickerPageModel info = TickerPageModel(
      symbol: data.symbol,
      companyName: data.companyName,
      marketPrice: data.price,
      percentChange: data.percentChange,
      isPostMarket: data.isPostMarket,
      postPercentChange: data.postPercentChange,
      priceChange: data.priceChange,
      postPriceChange: data.postPriceChange,
      openPrice: data.openPrice,
      chartDataX: data.chartDataX,
      chartDataY: data.chartDataY,
      isCrypto: data.isCrypto,
      isLive: data.isLive,
      isSaved: data.isSaved,
    );

    if (compleData != null) {
      info.postMarketPrice = compleData['postPrice'];
      info.shortName = compleData['shortName'];
      info.closeTime = compleData['marketCloseTime'];
      info.postCloseTime = compleData['postMarketCloseTime'];
    }
    return info;
  }
}
