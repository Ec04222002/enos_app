import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/article.dart';

class NewsAPI {
  // API key
  static const _api_key = "9945f33115msh2889748c34c8a59p156436jsnca35c9bb5bba";
  // Base API url
  static const String _baseUrl = "bing-news-search1.p.rapidapi.com";
  int apiIndex = 0;
  List<String> _apiKeys = [
    "9945f33115msh2889748c34c8a59p156436jsnca35c9bb5bba",
    "de6457e88cmsh9e1d1dab80a425dp1ae1f3jsnc28d0be79a56",
    "ecd583d7c6msh82839fd3dd7d7fep18f51fjsn1a7cee19b400",
    "3e4b16a5fcmsh98d8c8751778553p164b44jsnb5e4782d31b9",
    "0a9bd9ad36msh9da804e09688e05p1fcfcejsne6c5cc60e965",
    "402d2f8e5amsh4d113d00393064ep173f23jsn6c05b23ecc6d",
  ];

  static const String _default_thumbnail =
      "https://www.bing.com/th?id=OVFT.1SmHnJcnDkQ22RL1_HeluS&pid=News";
  // Base headers for Response url
  static Map<String, String> _headers = {
    "content-type": "application/json",
    "X-RapidAPI-Host": "bing-news-search1.p.rapidapi.com",
    "X-RapidAPI-Key": _api_key,
    "X-BingApis-SDK": "true"
  };

  static Map<String, List<String>> keywords = {
    "crypto": [],
    "stock": [],
    "all": [
      "crypto",
      "tech",
      "stock",
      "block chain",
      "shareholder",
      "technology",
      "cryptocurrency"
    ]
  };

  void resetApiKey(int index) {
    _headers = {
      "content-type": "application/json",
      "X-RapidAPI-Host": "bing-news-search1.p.rapidapi.com",
      "X-RapidAPI-Key": _apiKeys[index],
      "X-BingApis-SDK": "true"
    };
  }

  // Base API request to get response
  Future<List<ArticleModel>> get({
    @required String endpoint,
    @required Map<String, String> query,
  }) async {
    Uri uri = Uri.https(_baseUrl, endpoint, query);
    var response = await http.get(uri, headers: _headers);
    //**NEW :check for all api keys
    // ... if current api key died
    if (response.statusCode != 200) {
      for (var i = apiIndex + 1; i < _apiKeys.length; ++i) {
        resetApiKey(i);
        response = await http.get(uri, headers: _headers);
        if (response.statusCode == 200) {
          apiIndex = i;
          break;
        }
      }
      if (response.statusCode != 200) {
        throw Exception('Failed to load json data');
      }
    }
    // If server returns an OK response, parse the JSON.
    var results = jsonDecode(response.body);
    List<ArticleModel> ret = [];
    results['value'].forEach((element) {
      String provider, imageUrl;
      element['provider'].forEach((element1) {
        provider = element1['name'];
      });
      if (element['image'] == null || element['image']['thumbnail'] == null) {
        imageUrl = _default_thumbnail;
      } else {
        imageUrl = element['image']['thumbnail']['contentUrl'];
      }
      ret.add(ArticleModel(
          name: element['name'],
          url: element['url'],
          description: element['description'],
          datePublished: element['datePublished'].toString(),
          provider: provider,
          image: imageUrl));
    });
    return ret;
  }

  static Future<List<ArticleModel>> getArticles(
      String category, int offset) async {
    var api = NewsAPI();
    Future<List<ArticleModel>> results;
    if (category != "All")
      results = api.get(
          endpoint: "/news/search",
          query: {"q": category, "offset": "$offset", "count": "20"});
    else {
      String query = "crypto OR tech OR stock";
      results = api.get(
          endpoint: "/news/search",
          query: {"q": query, "offset": "$offset", "count": "20"});
    }
    return results;
  }
}
