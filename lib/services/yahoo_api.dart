import 'package:enos/models/ticker_tile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class YahooApi {
  static const selfApiKey =
      "3e4b16a5fcmsh98d8c8751778553p164b44jsnb5e4782d31b9";

  int apiIndex = 0;
  bool toggle = false;
  List<int> times = [3, 5];
  List<String> apiKeys = [
    "0a9bd9ad36msh9da804e09688e05p1fcfcejsne6c5cc60e965",
    "ecd583d7c6msh82839fd3dd7d7fep18f51fjsn1a7cee19b400",
    "3e4b16a5fcmsh98d8c8751778553p164b44jsnb5e4782d31b9"
  ];
  static const String _baseUrl = 'yh-finance.p.rapidapi.com';
  static Map<String, String> _headers = {
    'X-RapidAPI-Key': selfApiKey,
    'X-RapidAPI-Host': 'yh-finance.p.rapidapi.com'
  };

  int increApiIndex() {
    apiIndex = (apiIndex + 1) % apiKeys.length;
    return apiIndex;
  }

  void resetApiKey(int index) {
    _headers = {
      'X-RapidAPI-Key': apiKeys[index],
      'X-RapidAPI-Host': 'yh-finance.p.rapidapi.com'
    };
  }

  Future<TickerTileModel> get({
    @required String endpoint,
    @required Map<String, String> query,
  }) async {
    Uri uri = Uri.https(_baseUrl, endpoint, query);
    http.Response response = await http.get(uri, headers: _headers);
    var results = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final String symbol = results['quoteType']['symbol'];
      final String companyName = results['quoteType']['shortName'];
      final String price = results['price']["regularMarketPrice"]["fmt"];
      final String percentChange =
          results['price']['regularMarketChangePercent']["fmt"];

      return TickerTileModel(
        symbol: symbol,
        companyName: companyName,
        price: price,
        percentChange: percentChange,
      );
    }
    throw Exception("Failed to load json data");
  }

  Stream<TickerTileModel> getTileStream(String symbol) {
    int time = toggle ? times[0] : times[1];
    toggle = !toggle;
    return Stream.periodic(Duration(seconds: time))
        .asyncMap((_) => getTileData(symbol));
  }

  static Future<TickerTileModel> getTileData(String symbol) async {
    TickerTileModel data = await YahooApi().get(
        endpoint: "stock/v2/get-summary",
        query: {"symbol": symbol, "region": "US"});
    return data;
  }
}
