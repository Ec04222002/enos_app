import 'package:enos/models/article.dart';
import 'package:enos/models/comment.dart';
import 'package:enos/models/ticker_tile.dart';

class TickerPageModel {
  String symbol;
  String companyName;
  String marketPrice;
  dynamic marketPriceNum;
  dynamic postMarketPriceNum;
  String postMarketPrice;
  String percentChange;
  String postPercentChange;
  String priceChange;
  String postPriceChange;
  String shortName;
  String marketName;
  String msgBoardID;
  dynamic openPrice;
  dynamic previousClose;
  List chartDataY;
  List chartDataX;
  List<ArticleModel> articles;
  List<Comment> commentData = [];

  Map<String, Map<String, List>> priceData = {};
  Map<String, dynamic> specsData;
  // List closePriceData;
  // List highPriceData;
  // List lowPriceData;

  bool isCrypto;
  bool isPostMarket;
  bool isSaved;
  bool isLive;
  int closeTime;
  int postCloseTime;
  TickerPageModel({
    this.symbol,
    this.companyName,
    this.shortName,
    this.marketName,
    this.marketPrice,
    this.postMarketPrice,
    this.percentChange,
    this.isPostMarket = false,
    this.postPercentChange,
    this.priceChange,
    this.postPriceChange,
    this.previousClose,
    this.chartDataX,
    this.chartDataY,
    this.specsData,
    this.isCrypto = false,
    this.isLive = true,
    this.isSaved = false,
    this.msgBoardID,
    this.closeTime,
    this.postCloseTime,
  });

  static TickerPageModel fromTickerTileModel(
      {TickerTileModel data, dynamic compleData}) {
    TickerPageModel info = TickerPageModel(
      symbol: data.symbol,
      companyName: data.companyName,
      marketName: data.marketName,
      marketPrice: data.price,
      percentChange: data.percentChange,
      isPostMarket: data.isPostMarket,
      postPercentChange: data.postPercentChange,
      priceChange: data.priceChange,
      postPriceChange: data.postPriceChange,
      previousClose: data.previousClose,
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
      info.specsData = compleData['specsData'];
      info.msgBoardID = compleData['msgBoardID'];
      info.marketPriceNum = compleData['marketPriceNum'];
      info.postMarketPriceNum = compleData['postMarketPriceNum'];
    }
    return info;
  }
}
