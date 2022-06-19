import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/ticker_provider.dart';
import 'package:enos/services/util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class YahooApi {
  static const selfApiKey =
      "3e4b16a5fcmsh98d8c8751778553p164b44jsnb5e4782d31b9";

  int apiIndex = 0;
  //bac
  //
  List<String> apiKeys = [
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

  Future<TickerTileModel> get({
    bool init = false,
    @required String endpoint,
    @required Map<String, String> query,
  }) async {
    //throw Exception("Temp stop");
    //add time restrictions
    // throw error
    var results;
    for (var i = 0; i < apiKeys.length; ++i) {
      resetApiKey(i);
      results = await getData(endpoint: endpoint, query: query);
      if (results != null) {
        break;
      }
    }
    if (results == null) {
      throw Exception("Surpassed Api Limit");
    }

    final String symbol = results['quoteType']['symbol'];
    final String companyName = results['quoteType']['shortName'];
    final String price = results['price']["regularMarketPrice"]["fmt"];
    final String percentChange =
        results['price']['regularMarketChangePercent']["fmt"];
    final bool isPost = !(results['price']["exchangeName"].contains("OTC") ||
        results['quoteType']['quoteType'].contains("INDEX"));
    final bool isCrypto = results['quoteType']['quoteType'] == "CRYPTOCURRENCY";

    final priceChange = results['price']["regularMarketChange"]['fmt'];
    String postPercentChange;
    String postPriceChange;
    if (isPost && !isCrypto) {
      postPercentChange = results['price']['postMarketChangePercent']['fmt'];
      postPriceChange = results['price']['postMarketChange']['fmt'];
    }
    print("isPost: $isPost");
    print("isCrypto: $isCrypto");
    TickerTileModel data = TickerTileModel(
      symbol: symbol,
      companyName: companyName,
      price: price,
      percentChange: percentChange,
      postPercentChange: postPercentChange,
      priceChange: priceChange,
      postPriceChange: postPriceChange,
      isCrypto: isCrypto,
      isPostMarket: isPost,
    );
    if (!Utils.isMarketTime() && !isPost) {
      print("***");
      data.isLive = false;
    }
    if (Utils.isPastPostMarket()) {
      data.isLive = false;
    }
    return data;
  }
}
