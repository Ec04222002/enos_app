import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/article.dart';

class NewsAPI {
  // API key
  static const _api_key = "9945f33115msh2889748c34c8a59p156436jsnca35c9bb5bba";
  // Base API url
  static const String _baseUrl = "bing-news-search1.p.rapidapi.com";

  static const String _default_thumbnail = "https://www.bing.com/th?id=OVFT.1SmHnJcnDkQ22RL1_HeluS&pid=News";
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
  Future<List<ArticleModel>> get({
    @required String endpoint,
    @required Map<String, String> query,
  }) async {
    Uri uri = Uri.https(_baseUrl, endpoint, query);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      var results = jsonDecode(response.body);
      List<ArticleModel> ret = [];
      results['value'].forEach((element) {
          String provider, imageUrl;
          element['provider'].forEach((element1) {
            provider = element1['name'];
          });
          if(element['image'] == null || element['image']['thumbnail'] == null) {
            imageUrl = _default_thumbnail;
          } else {
            imageUrl = element['image']['thumbnail']['contentUrl'];
          }
          ret.add(ArticleModel(
            name:element['name'],
            url: element['url'],
            description: element['description'],
            datePublished: element['datePublished'],
            provider: provider,
            image: imageUrl
          ));
      });
      print(ret.length);
      return ret;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data');
    }
  }
  static Future<List<ArticleModel>> getArticles(String category, int offset) async {
    var api = NewsAPI();
    Future<List<ArticleModel>> results = api.get(endpoint: "/news/search", query: {"q":category,"offset":"$offset"});
    return results;
  }
}