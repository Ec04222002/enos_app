import 'dart:io';

import 'package:enos/models/article.dart';
import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/ticker_spec.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/screens/news.dart';
import 'package:enos/services/news_api.dart';
import 'package:enos/services/yahoo_api.dart';

class TickerPageInfo {
  //TickerPageInfo({this.tileData});
  TickerPageModel lastData;
  static List chartRangeAndInt = const [
    ["1d", "5m"],
    ["5d", "15m"],
    ['1mo', '30m'],
    ['6mo', '1d'],
    ['1y', '1d'],
    ['5y', '1wk'],
    ['max', '1mo']
  ];
  YahooApi api = YahooApi();
  bool isLowData = false;
  Future<void> getChartInfo(TickerPageModel preData, int i) async {
    if (isLowData) {
      preData.priceData[chartRangeAndInt[i][0]] = {};
      return;
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
      }
      pre = chartResult['chart']['result'][0]["indicators"]['quote'][0];
      initClosePriceData = pre["close"];
      initLowPriceData = pre["low"];
      initHighPriceData = pre["high"];
      initOpenPriceData = pre['open'];
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
  }

  Future<void> getNewsInfo(TickerPageModel preData) async {
    dynamic newsResult = await api.getNewsData(preData.symbol, 15);
    if (newsResult == null) {
      for (var i = api.validApiIndex + 1; i < api.apiKeys.length; ++i) {
        api.resetApiKey(i);
        newsResult = await api.getNewsData(preData.symbol, 12);
        if (newsResult != null) {
          api.validApiIndex = i;
          break;
        }
      }
      // results are still null => checked all apis and all is surpassed
      if (newsResult == null) {
        throw Exception("Surpassed Api Limit");
      }
    }
    List<dynamic> streams = newsResult['data']['main']['stream'];
    List<dynamic> storyStreams =
        streams.where((e) => e['content']['contentType'] == "STORY").toList();
    preData.articles =
        List<ArticleModel>.generate(storyStreams.length, (index) {
      dynamic parent = storyStreams[index]['content'];
      return ArticleModel(
          uuid: parent['id'],
          shortName: preData.companyName,
          name: parent['title'],
          url: parent['clickThroughUrl'] != null
              ? parent['clickThroughUrl']['url']
              : "",
          image: (() {
            dynamic pre = parent['thumbnail'];
            if (pre == null) return NewsAPI.defaultThumbnail;
            dynamic resolutions = pre['resolutions'];
            int i = 3;
            dynamic img = resolutions[i];
            while (img == null) {
              if (i == 1) {
                return NewsAPI.defaultThumbnail;
              }
              img = resolutions[--i];
            }

            return img['url'];
          })(),
          provider: parent['provider']['displayName'],
          datePublished: parent['pubDate']);
    });
  }

  Future<void> addPostPostLoadData(TickerPageModel preData) async {
    List<int> articleIndexToRemove = [];
    for (int index = 0; index < preData.articles.length; ++index) {
      ArticleModel article = preData.articles[index];
      String link = article.url;

      if (link.isEmpty) {
        dynamic details = await api.getArticleLink(article.uuid);
        dynamic data = details['data']['contents'][0]['content'];
        List<String> links = [
          data['ampUrl'],
          data['canonicalUrl'] != null ? data['canonicalUrl']['url'] : null,
          data['clickThroughUrl'] != null
              ? data['clickThroughUrl']['url']
              : null,
        ];

        for (String l in links) {
          if (l != null && l.isNotEmpty) {
            link = l;
            break;
          }
        }
      }

      if (link != null && link.isNotEmpty) {
        preData.articles[index].url = link;
        continue;
      }

      //didn't find article url
      articleIndexToRemove.add(index);
    }

    if (articleIndexToRemove.isNotEmpty) {
      //descending order
      articleIndexToRemove.sort((a, b) => b.compareTo(a));
      print("indexs : $articleIndexToRemove");
      for (int index in articleIndexToRemove) {
        preData.articles.removeAt(index);
      }
    }
  }

  Future<void> addPostLoadData(TickerPageModel preData) async {
    //retrieving chart range data
    for (var i = 0; i < chartRangeAndInt.length; ++i) {
      await getChartInfo(preData, i);
    }
    await getNewsInfo(preData);
    //add comment data
  }

  Stream<TickerPageModel> getPageStream(
      String symbol, bool isSaved, TickerPageModel lastData) {
    return Stream.periodic(Duration(seconds: 1)).asyncMap((_) {
      return getModelData(symbol, isSaved, true, lastData);
    });
  }

  Future<void> setStreamChart(TickerPageModel data) async {
    int currentEpoch = (DateTime.now().millisecondsSinceEpoch / 1000).round();
//updating charts
    if (data.priceData != null) {
      if (data.priceData['1d'] != null &&
          data.priceData['1d']['timeStamps'].last < currentEpoch - 300) {
        getChartInfo(data, 0);
      }
      if (data.priceData['5d'] != null &&
          data.priceData['5d']['timeStamps'].last < currentEpoch - 900) {
        getChartInfo(data, 1);
      }
    }
  }

  //yahoo api and fill necessary data
  Future<TickerPageModel> getModelData(String symbol, bool isSaved,
      bool isStream, TickerPageModel lastData) async {
    YahooApi api = YahooApi();
    print("setting init data");
    dynamic tickerResult = await api.getTickerData(symbol);

    if (isStream) {
      //get frequent datas
      Map<String, dynamic> specs = TickerSpecs.apiToMap(tickerResult);
      lastData.specsData = specs;
      lastData.marketPrice = tickerResult['price']['regularMarketPrice']['fmt'];
      lastData.percentChange =
          tickerResult['price']['regularMarketChangePercent']['fmt'];

      lastData.postPercentChange = lastData.isCrypto
          ? null
          : tickerResult['price']['postMarketChangePercent']['fmt'];

      lastData.priceChange =
          tickerResult['price']["regularMarketChange"]['fmt'];
      lastData.postPriceChange =
          tickerResult['price']['postMarketChange']['fmt'];
      lastData.previousClose =
          tickerResult['price']['regularMarketPreviousClose']["raw"].toDouble();
      lastData.postMarketPrice = lastData.isPostMarket
          ? tickerResult['price']['postMarketPrice']['fmt']
          : null;
      lastData.postMarketPriceNum = lastData.isPostMarket
          ? tickerResult['price']['postMarketPrice']['raw']
          : null;
      lastData.closeTime = tickerResult['price']['regularMarketTime'];
      //new var
      lastData.marketPriceNum =
          tickerResult['price']['regularMarketPrice']['raw'];
      setStreamChart(lastData);
      print("Streaming..");
      return lastData;
    }
    TickerTileModel tileModel =
        await api.get(symbol: symbol, chartInterval: "5m");
    tileModel.isSaved = isSaved;
    Map<String, dynamic> specsData = TickerSpecs.apiToMap(tickerResult);
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
      'postMarketPriceNum': tickerResult['price']['postMarketPrice']['raw'],
      'marketPriceNum': tickerResult['price']['regularMarketPrice']['raw'],
      'specsData': specsData,
      'msgBoardID': tickerResult['quoteType']['messageBoardId']
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
