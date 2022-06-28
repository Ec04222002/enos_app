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
    "stock" : [],
    "all": ["crypto","tech","stock","block chain", "shareholder", "technology", "cryptocurrency"]
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
      return ret;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data');
    }
  }
  static Future<List<ArticleModel>> getArticles(String category, int offset) async {
    var api = NewsAPI();
    Future<List<ArticleModel>> results;
    if(category != "All")
      results = api.get(endpoint: "/news/search", query: {"q":category,"offset":"$offset","count":"20"});
    else {
      String query = "crypto OR tech OR stock";
      results = api.get(endpoint: "/news/search", query: {"q":query,"offset":"$offset","count":"20"});
    }
    return results;
  }
}