import 'package:enos/models/search_tile.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class YahooApi {
  static const selfApiKey =
      "de6457e88cmsh9e1d1dab80a425dp1ae1f3jsnc28d0be79a56";
  int validApiIndex = 0;
  List<String> apiKeys = [
    "de6457e88cmsh9e1d1dab80a425dp1ae1f3jsnc28d0be79a56"
        "ecd583d7c6msh82839fd3dd7d7fep18f51fjsn1a7cee19b400",
    "3e4b16a5fcmsh98d8c8751778553p164b44jsnb5e4782d31b9",
    "0a9bd9ad36msh9da804e09688e05p1fcfcejsne6c5cc60e965",
    "402d2f8e5amsh4d113d00393064ep173f23jsn6c05b23ecc6d",
  ];
  static const String _baseUrl = 'yh-finance.p.rapidapi.com';
  static Map<String, String> _headers = {
    'X-RapidAPI-Key': selfApiKey,
    'X-RapidAPI-Host': 'yh-finance.p.rapidapi.com'
  };

  void resetApiKey(int index) {
    _headers = {
      'X-RapidAPI-Key': apiKeys[index],
      'X-RapidAPI-Host': 'yh-finance.p.rapidapi.com'
    };
  }

  dynamic getData({
    @required String endpoint,
    @required Map<String, String> query,
  }) async {
    Uri uri = Uri.https(_baseUrl, endpoint, query);
    http.Response response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  dynamic postData(
      {String body = "",
      @required String endPoint,
      @required Map<String, String> query}) async {
    Uri uri = Uri.https(_baseUrl, endPoint, query);

    http.Response response =
        await http.post(uri, headers: _headers, body: body);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    return null;
  }

  Future<dynamic> getRecommendedStockList({int count = 6}) async {
    final response = await getData(
        endpoint: "market/get-trending-tickers", query: {"region": "US"});

    if (response == null) throw Exception("Error getting recommend stocks");

    final List quotes = response['finance']['result'][0]['quotes'];
    var quotesFirstSix = quotes.take(6);
    return quotesFirstSix.map((json) => SearchTile.fromJson(json)).toList();
  }

  Future<dynamic> getArticleLink(String uuid) async {
    return await getData(endpoint: "news/v2/get-details", query: {
      'uuid': uuid,
    });
  }

  Future<dynamic> getTickerData(String symbol) async {
    return await getData(
        endpoint: "stock/v2/get-summary",
        query: {"symbol": symbol, "region": "US"});
  }

  Future<dynamic> getNewsData(String symbol, int count) async {
    return await postData(
        endPoint: 'news/v2/list',
        query: {'s': symbol, 'snippetCount': count.toString(), 'region': "US"});
  }

  Future<dynamic> getChartData(
      {String symbol, String interval = "15m", String range = "1d"}) async {
    return await getData(endpoint: "stock/v3/get-chart", query: {
      "symbol": symbol,
      "interval": interval,
      "range": range,
      "events": "",
    });
  }

  Future<List<TickerTileModel>> getWatchlistUpdates(
      List<String> symbols, bool requestChart) async {
    if (symbols.isEmpty) return [];
    String searchQuery = symbols.join(",");
    dynamic datas = await getData(endpoint: "market/v2/get-quotes", query: {
      "symbols": searchQuery,
    });
    List<TickerTileModel> listData = [];
    //print("in yahoo api");
    if (datas == null) {
      throw Exception("Cannot get init ticker data");
    }
    for (dynamic response in datas['quoteResponse']['result']) {
      String tickerSymbol = response['symbol'],
          companyName = response['shortName'] == null
              ? response['longName']
              : response['shortName'],
          price = Utils.fixNumToFormat(
              num: response['regularMarketPrice'],
              isPercentage: false,
              isConstrain: false),
          percentChange = Utils.fixNumToFormat(
              num: response['regularMarketChangePercent'],
              isPercentage: true,
              isConstrain: true),
          priceChange = Utils.fixNumToFormat(
              num: response['regularMarketChange'],
              isPercentage: false,
              isConstrain: true),
          postPercentChange,
          postPriceChange;

      double previousClose = response['regularMarketPreviousClose'],
          priceNum = response['regularMarketPrice'].toDouble();
      bool isCrypto = (response['quoteType'] == "CRYPTOCURRENCY"),
          isPost = !(response["fullExchangeName"].contains("OTC") ||
              response['quoteType'].contains("INDEX") ||
              response['postMarketChange'] == null);
      ;
      //finding marketname
      String marketName = response['fullExchangeName'].toString().toUpperCase();
      if (isCrypto)
        marketName = "Crypto";
      else if (marketName.contains("OTC"))
        marketName = "OTCBB";
      else if (tickerSymbol.startsWith("^"))
        marketName = "INDEX";
      else if (marketName != "NYSE") marketName = "NASDAQ";
      if (isPost && !isCrypto && (!Utils.isMarketTime() || Utils.isWeekend())) {
        if (response['postMarketChangePercent'] != null) {
          postPercentChange = Utils.fixNumToFormat(
              num: response['postMarketChangePercent'],
              isPercentage: true,
              isConstrain: true);
          postPriceChange = Utils.fixNumToFormat(
              num: response['postMarketChange'],
              isPercentage: false,
              isConstrain: true);
        }
      }
      listData.add(await get(
          symbol: tickerSymbol,
          lastData: TickerTileModel(
            priceNum: priceNum,
            symbol: tickerSymbol,
            companyName: companyName,
            price: price,
            priceChange: priceChange,
            percentChange: percentChange,
            postPercentChange: postPercentChange,
            postPriceChange: postPriceChange,
            previousClose: previousClose,
            isCrypto: isCrypto,
            isPostMarket: isPost,
            isSaved: true,
            marketName: marketName,
          ),
          requestTickerData: false,
          requestChartData: requestChart));
    }
    return listData;
  }

  Future<List<TickerTileModel>> getInitTickers(List<String> symbols) async {
    return getWatchlistUpdates(symbols, true);
  }

  Future<TickerTileModel> get(
      {@required String symbol,
      TickerTileModel lastData,
      bool requestChartData = true,
      String chartRange = "1d",
      String chartInterval = "15m",
      bool requestTickerData = true}) async {
    lastData = lastData == null ? TickerTileModel() : lastData;

    var results;
    String tickerSymbol = lastData.symbol,
        companyName = lastData.companyName,
        price = lastData.price,
        percentChange = lastData.percentChange,
        priceChange = lastData.priceChange,
        postPercentChange = lastData.postPercentChange,
        postPriceChange = lastData.postPriceChange,
        marketName = lastData.marketName;
    double previousClose = lastData.previousClose, priceNum = lastData.priceNum;
    bool isPost = lastData.isPostMarket,
        isCrypto = lastData.isCrypto,
        isSaved = lastData.isSaved;

    if (requestTickerData) {
      results = await getTickerData(symbol);
      //if results null => current api key surpassed
      if (results == null) {
        //check all api keys to get valid api key
        for (var i = 0; i < apiKeys.length; ++i) {
          resetApiKey(i);
          results = await getTickerData(symbol);
          if (results != null) {
            validApiIndex = i;
            break;
          }
        }
        // if result persist to be null => all api keys surpassed
        if (results == null) {
          throw Exception("Surpassed Api Limit");
        }
      }
      priceNum = results['price']['regularMarketPrice']['raw'].toDouble();
      tickerSymbol = results['quoteType']['symbol'];
      companyName = results['quoteType']['shortName'] == null
          ? results['quoteType']['longName']
          : results['quoteType']['shortName'];

      price = results['price']["regularMarketPrice"]["fmt"];
      percentChange = results['price']['regularMarketChangePercent']["fmt"];
      previousClose =
          results['price']['regularMarketPreviousClose']["raw"].toDouble();
      isPost = !(results['price']["exchangeName"].contains("OTC") ||
          results['quoteType']['quoteType'].contains("INDEX") ||
          results['price']['postMarketChange']['fmt'] == null);
      isCrypto = results['quoteType']['quoteType'] == "CRYPTOCURRENCY";
      priceChange = results['price']["regularMarketChange"]['fmt'];

      //finding marketname
      marketName = results['price']['exchangeName'].toString().toUpperCase();
      if (isCrypto)
        marketName = "CRYPTO";
      else if (marketName.contains("OTC"))
        marketName = "OTCBB";
      else if (tickerSymbol.startsWith("^"))
        marketName = "INDEX";
      else if (marketName != "NYSE") marketName = "NASDAQ";

      if (isPost && !isCrypto && (!Utils.isMarketTime() || Utils.isWeekend())) {
        if (results['price']['postMarketChangePercent']['fmt'] != null) {
          postPercentChange =
              results['price']['postMarketChangePercent']['fmt'];
          postPriceChange = results['price']['postMarketChange']['fmt'];
        }
      }
    }

    var chartResults;
    List<dynamic> initChartDataY;
    List<dynamic> initChartDataX;
    List chartDataX = lastData.chartDataX;
    List chartDataY = lastData.chartDataY;
    if (requestChartData) {
      //print("getting chart data");
      // using last working header
      chartResults = await getChartData(
          symbol: symbol, range: chartRange, interval: chartInterval);
      //In case api just hit limit => look for valid api keys again
      if (chartResults == null) {
        for (var i = validApiIndex + 1; i < apiKeys.length; ++i) {
          resetApiKey(i);
          chartResults = await getChartData(
              symbol: symbol, range: chartRange, interval: chartInterval);
          if (chartResults != null) {
            validApiIndex = i;
            break;
          }
        }
        // results are still null => checked all apis and all is surpassed
        if (chartResults == null) {
          throw Exception("Surpassed Api Limit");
        }
      }

      if (chartResults != null) {
        initChartDataY = chartResults['chart']['result'][0]["indicators"]
            ["quote"][0]["open"];
        initChartDataX = chartResults['chart']['result'][0]["timestamp"];
        chartDataY = [];
        chartDataX = [];
        double lastNonNullData;
        for (int i = 0; i < initChartDataX.length; ++i) {
          if (initChartDataY[i] != null) {
            lastNonNullData = initChartDataY[i].toDouble();
            chartDataY.add(initChartDataY[i].toDouble());
          } else if (lastNonNullData != null) {
            //print("adding last: ${lastNonNullData}");
            chartDataY.add(lastNonNullData);
          }
          chartDataX.add(initChartDataX[i].toDouble());
        }
      }
    }
    //print(tickerSymbol);
    //print("isPost: $isPost");
    // //print("isCrypto: $isCrypto");
    TickerTileModel data = TickerTileModel(
      priceNum: priceNum,
      symbol: tickerSymbol,
      companyName: companyName,
      price: price,
      percentChange: percentChange,
      postPercentChange: postPercentChange,
      priceChange: priceChange,
      postPriceChange: postPriceChange,
      previousClose: previousClose,
      chartDataX: chartDataX,
      chartDataY: chartDataY,
      isCrypto: isCrypto,
      isPostMarket: isPost,
      isSaved: isSaved,
      marketName: marketName,
    );
    if (!Utils.isMarketTime() && !isPost) {
      data.isLive = false;
    }
    if (Utils.isPastPostMarket() && !isCrypto) {
      data.isLive = false;
    }
    if (isCrypto) data.isLive = true;
    return data;
  }
}
