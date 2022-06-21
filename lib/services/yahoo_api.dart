import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class YahooApi {
  static const selfApiKey =
      "de6457e88cmsh9e1d1dab80a425dp1ae1f3jsnc28d0be79a56";

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

  Future<TickerTileModel> get(
      {@required String symbol, TickerTileModel lastData}) async {
    //checking all api keys
    var results;
    var chartResults;
    for (var i = 0; i < apiKeys.length; ++i) {
      resetApiKey(i);
      results = await getData(
          endpoint: "stock/v2/get-summary",
          query: {"symbol": symbol, "region": "US"});
      //preventing extra chart data call
      if (results == null) {
        continue;
      }
      // api only has markettime data for charts
      // but always run during init or when lastData is not present
      if (Utils.isMarketTime() || lastData == null) {
        chartResults = await getData(endpoint: "stock/v3/get-chart", query: {
          "symbol": symbol,
          "interval": "30m",
          "range": "1d",
          "region": "US"
        });
      }
      if (chartResults != null) {
        break;
      }
    }
    if (chartResults == null) {
      throw Exception("Surpassed Api Limit");
    }

    final String tickerSymbol = results['quoteType']['symbol'];
    final String companyName = results['quoteType']['shortName'];
    final String price = results['price']["regularMarketPrice"]["fmt"];
    final String percentChange =
        results['price']['regularMarketChangePercent']["fmt"];
    final double openPrice = results['price']['regularMarketOpen']["raw"];
    final bool isPost = !(results['price']["exchangeName"].contains("OTC") ||
        results['quoteType']['quoteType'].contains("INDEX"));
    final bool isCrypto = results['quoteType']['quoteType'] == "CRYPTOCURRENCY";
    final String priceChange = results['price']["regularMarketChange"]['fmt'];
    List chartDataX;
    List chartDataY;
    if (chartResults != null) {
      List<dynamic> initChartDataY =
          chartResults['chart']['result'][0]["indicators"]["quote"][0]["open"];
      chartDataY = initChartDataY.map((e) => e.toDouble()).toList();
      List<dynamic> initChartDataX =
          chartResults['chart']['result'][0]["timestamp"];
      chartDataX = initChartDataX.map((e) => e.toDouble()).toList();
    } else {
      chartDataX = lastData.chartDataX;
      chartDataY = lastData.chartDataY;
    }
    ;

    String postPercentChange;
    String postPriceChange;
    if (isPost && !isCrypto) {
      postPercentChange = results['price']['postMarketChangePercent']['fmt'];
      postPriceChange = results['price']['postMarketChange']['fmt'];
    }
    // print("isPost: $isPost");
    // print("isCrypto: $isCrypto");
    TickerTileModel data = TickerTileModel(
      symbol: tickerSymbol,
      companyName: companyName,
      price: price,
      percentChange: percentChange,
      postPercentChange: postPercentChange,
      priceChange: priceChange,
      postPriceChange: postPriceChange,
      openPrice: openPrice,
      chartDataX: chartDataX,
      chartDataY: chartDataY,
      isCrypto: isCrypto,
      isPostMarket: isPost,
    );
    if (!Utils.isMarketTime() && !isPost) {
      data.isLive = false;
    }
    if (Utils.isPastPostMarket() && !isCrypto) {
      data.isLive = false;
    }
    return data;
  }
}
