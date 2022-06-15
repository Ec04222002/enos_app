import 'package:enos/models/ticker_tile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class YahooApi {
  static const _apiKey = "0a9bd9ad36msh9da804e09688e05p1fcfcejsne6c5cc60e965";
  static const String _baseUrl = 'yh-finance.p.rapidapi.com';
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key': _apiKey,
    'X-RapidAPI-Host': 'yh-finance.p.rapidapi.com'
  };

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
}
