import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/article.dart';

class NewsAPI {
  // API key
  static const _api_key = "9945f33115msh2889748c34c8a59p156436jsnca35c9bb5bba";
  // Base API url
  static const String _baseUrl = "bing-news-search1.p.rapidapi.com";
  // Base headers for Response url
  static const Map<String, String> _headers = {
    "content-type": "application/json",
    "X-RapidAPI-Host": "bing-news-search1.p.rapidapi.com",
    "X-RapidAPI-Key": _api_key,
    "X-BingApis-SDK" : "true"
  };

  static Map<String, List<String>> keywords = {
    "crypto" : [],
    "stock" : []
  };

  // Base API request to get response
  Future<dynamic> get({
    @required String endpoint,
    @required Map<String, String> query,
  }) async {
    Uri uri = Uri.https(_baseUrl, endpoint, query);
    var uu = Uri.parse(_baseUrl);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      var results = jsonDecode(response.body);
      print(results.toString());
      results['value'].forEach((element) {
        print('yoo ' + element['url']);
      });
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data');
    }
  }
  static Future<ArticleModel> getArticles(String category) async {
    var api = NewsAPI();
    var results = api.get(endpoint: "/news/search", query: {"q":"keyword:(intitle)crypto OR keyword:(intitle)blockchain OR keyword:(intitle)bitcoin"});

    ArticleModel ret = ArticleModel();
    return ret;
  }
}