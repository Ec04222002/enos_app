import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/yahoo_api.dart';

class TickerPageInfo {
  //TickerPageInfo({this.tileData});

  static Future<void> addPostLoadData(TickerPageModel preData) async {
    print("adding post data");
    YahooApi api = YahooApi();
    List initClosePriceData, closePriceData = [];
    List initHighPriceData, highPriceData = [];
    List initLowPriceData, lowPriceData = [];

    dynamic chartResult = await api.getChartData(symbol: preData.symbol);
    //In case api just hit limit => look for valid api keys again
    if (chartResult == null) {
      for (var i = api.validApiIndex + 1; i < api.apiKeys.length; ++i) {
        api.resetApiKey(i);
        chartResult = await api.getChartData(symbol: preData.symbol);
        if (chartResult != null) {
          api.validApiIndex = i;
          break;
        }
      }
      // results are still null => checked all apis and all is surpassed
      if (chartResult == null) {
        throw Exception("Surpassed Api Limit");
      }
    }

    if (chartResult != null) {
      List timeData = chartResult['chart']['result'][0]["timestamp"];
      dynamic pre = chartResult['chart']['result'][0]["indicators"]['quote'][0];
      initClosePriceData = pre["close"];
      initLowPriceData = pre["low"];
      initHighPriceData = pre["high"];
      List datas = [
        {"data": closePriceData, "init": initClosePriceData},
        {"data": lowPriceData, "init": initLowPriceData},
        {"data": highPriceData, "init": initHighPriceData}
      ];
      datas.forEach((data) {
        double lastNonNullData;
        for (int i = 0; i < timeData.length; ++i) {
          if (data['init'][i] != null) {
            lastNonNullData = data['init'][i].toDouble();
            data['data'].add(data["init"][i].toDouble());
          } else if (lastNonNullData != null) {
            print("adding last: ${lastNonNullData}");
            data['data'].add(lastNonNullData);
          } else {
            data['data'].add(data['init'].first.toDouble());
          }
        }
      });
      //print("closePriceData: $closePriceData");
    }
    print("setting post data");
    preData.closePriceData = closePriceData;
    preData.highPriceData = highPriceData;
    preData.lowPriceData = lowPriceData;
  }

  //yahoo api and fill necessary data
  static Future<TickerPageModel> getModelData(
      String symbol, bool isSaved) async {
    YahooApi api = YahooApi();
    print("setting init data");
    TickerTileModel tileModel = await api.get(symbol: symbol);
    tileModel.isSaved = isSaved;
    dynamic tickerResult = await api.getTickerData(symbol);
    print("post: ${tileModel.isPostMarket}");
    Map<String, dynamic> compleData = {
      "postPrice": tileModel.isPostMarket
          ? tickerResult['price']['postMarketPrice']['fmt']
          : null,
      'shortName': tickerResult['quoteType']['shortName'].toString(),
      'marketCloseTime': tickerResult['price']['regularMarketTime'],
      'postMarketCloseTime': tileModel.isPostMarket
          ? tickerResult['price']['postMarketTime']
          : null,
    };
    TickerPageModel pageModel = TickerPageModel.fromTickerTileModel(
        data: tileModel, compleData: compleData);
    //dynamic news = await api.
    return pageModel;
    //load complement data
  }

  //reduce the full company name to fit
  static String shortName(String companyName) {
    String fullName = companyName;
    List<String> listWords = fullName.split(" ");
    return listWords[0] + " " + listWords[1];
  }
}
