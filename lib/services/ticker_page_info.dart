import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/yahoo_api.dart';

class TickerPageInfo {
  //TickerPageInfo({this.tileData});
  static List chartRangeAndInt = const [
    ["1d", "5m"],
    ["5d", "15m"],
    ['1mo', '60m'],
    ['6mo', '1d'],
    ['1y', '1d'],
    ['5y', '1wk'],
    ['max', '1mo']
  ];
  static Future<void> addPostLoadData(TickerPageModel preData) async {
    YahooApi api = YahooApi();
    bool isLowData = false;
    for (var i = 0; i < chartRangeAndInt.length; ++i) {
      if (isLowData) {
        print("low data - not calling");
        preData.priceData[chartRangeAndInt[i][0]] = {};
        continue;
      }
      List initClosePriceData, closePriceData = [];
      List initHighPriceData, highPriceData = [];
      List initLowPriceData, lowPriceData = [];
      List initOpenPriceData, openPriceData = [];
      dynamic chartResult = await api.getChartData(
          symbol: preData.symbol,
          range: chartRangeAndInt[i][0],
          interval: chartRangeAndInt[i][1]);
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
      dynamic pre;
      List timeData;
      List datas;
      if (chartResult != null) {
        timeData = chartResult['chart']['result'][0]["timestamp"]
            .map((i) => i.toDouble())
            .toList();
        //preventing anymore calls if above data is insufficient
        //must have 1 day price though
        if (timeData.length < 3 && i != 0) {
          isLowData = true;
          preData.priceData[chartRangeAndInt[i][0]] = {};
          continue;
        }
        pre = chartResult['chart']['result'][0]["indicators"]['quote'][0];
        initClosePriceData = pre["close"];
        initLowPriceData = pre["low"];
        initHighPriceData = pre["high"];
        initOpenPriceData = pre['open'];
        print("data for: ${chartRangeAndInt[i][0]}");
        datas = [
          {"data": closePriceData, "init": initClosePriceData},
          {"data": lowPriceData, "init": initLowPriceData},
          {"data": highPriceData, "init": initHighPriceData},
          {'data': openPriceData, 'init': initOpenPriceData},
        ];
        datas.forEach((data) {
          double lastNonNullData;
          for (int i = 0; i < timeData.length; ++i) {
            if (data['init'][i] != null) {
              lastNonNullData = data['init'][i].toDouble();
              data['data'].add(data["init"][i].toDouble());
            } else if (lastNonNullData != null) {
              data['data'].add(lastNonNullData);
            } else {
              data['data'].add(data['init'].first.toDouble());
            }
          }
        });
        //print("closePriceData: $closePriceData");
      }
      preData.priceData[chartRangeAndInt[i][0]] = {
        'openPrices': openPriceData,
        'timeStamps': timeData,
        'closePrices': closePriceData,
        'highPrices': highPriceData,
        'lowPrices': lowPriceData,
      };

      print("openPrice: ${openPriceData.length}");
      print("closePrices: ${closePriceData.length}");
    }
  }

  //yahoo api and fill necessary data
  static Future<TickerPageModel> getModelData(
      String symbol, bool isSaved) async {
    YahooApi api = YahooApi();
    print("setting init data");
    TickerTileModel tileModel =
        await api.get(symbol: symbol, chartInterval: "5m");
    tileModel.isSaved = isSaved;
    dynamic tickerResult = await api.getTickerData(symbol);
    //print("post: ${tileModel.previousClose}");
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
