import 'package:flutter/scheduler.dart';

class TickerSpecs {
  // final List<double> dailyRange;
  // final List<double> monthRange;
  // final List<double> yearRange;
  // final double openPrice;
  // final double closePrice;
  // final double previousClosePrice;
  // final double volume;
  // final double trailingPE;
  // final double forwardPE;
  // final double marketCap;
  // final double avgDailyVol10day;
  // final double avgDailyVol3mo;
  // final double profitMargin;
  // final double forwardEPS;
  // final double trailingEPS;
  // final double bookValue;
  // final double yield;
  // final double beta;
  // final DateTime earningDate;
  // final double dividend;
  // final double lastDividend;
  // final double YTDReturn;
  static Map<String, dynamic> apiToMap(dynamic response) {
    Map<String, dynamic> existSpecsMap = {};
    dynamic parent = response['defaultKeyStatistics'];
    dynamic parent2 = response['summaryDetail'];
    dynamic parent3 = response['price'];
    dynamic parent4 = response['calendarEvents'];
    existSpecs.forEach((specs) {
      switch (specs) {
        case "Daily Range":
          existSpecsMap[specs] =
              parent2['dayLow']['fmt'] + "-" + parent2['dayHigh']['fmt'];

          break;

        case "52 Week Range":
          existSpecsMap[specs] = parent2['fiftyTwoWeekLow']['fmt'] +
              "-" +
              parent2['fiftyTwoWeekHigh']['fmt'];
          break;
        case "Open":
          existSpecsMap[specs] = parent3['regularMarketOpen']['fmt'];
          break;
        case 'Previous Close':
          existSpecsMap[specs] = parent2['previousClose']['fmt'];
          break;
        case 'Volume':
          existSpecsMap[specs] = parent2['volume']['fmt'];
          break;
        case 'Volume (24h)':
          existSpecsMap[specs] = parent2['volume24Hr']['fmt'];
          break;
        case "Trailing PE":
          existSpecsMap[specs] = parent2['trailingPE']['fmt'];
          break;
        case "Forward PE":
          existSpecsMap[specs] = parent2['forwardPE']['fmt'];
          break;
        case "Market Cap":
          existSpecsMap[specs] = parent2['marketCap']['fmt'];
          break;
        case "Avg Daily Vol (10d)":
          existSpecsMap[specs] = parent2['averageDailyVolume10Day']['fmt'];
          break;
        case "Avg Daily Vol (3mo)":
          existSpecsMap[specs] = parent3['averageDailyVolume3Month']['fmt'];
          break;
        case "Profit Margin":
          existSpecsMap[specs] =
              "${parent['profitMargins']['raw']}(${parent['profitMargins']})";
          break;
        case "Trailing EPS":
          existSpecsMap[specs] = parent['trailingEps']['fmt'];
          break;
        case "Forward EPS":
          existSpecsMap[specs] = parent['forwardEps']['fmt'];
          break;
        case "Book Value":
          existSpecsMap[specs] = parent['bookValue']['fmt'];
          break;
        case "Yield":
          existSpecsMap[specs] = parent['yield']['fmt'];
          break;
        case "Earning Date":
          existSpecsMap[specs] = parent4['earnings']['earningsDate'] == null
              ? "__"
              : parent4['earnings']['earningsDate']['fmt'];
          break;
        case "Ex-dividend Date":
          existSpecsMap[specs] = parent4['exDividendDate']['fmt'];
          break;
        case "Dividend Date":
          existSpecsMap[specs] = parent4['dividendDate']['fmt'];
          break;
        case "Last Dividend":
          existSpecsMap[specs] = parent['lastDividendValue']['fmt'];
          break;
        case "YTD Return":
          existSpecsMap[specs] = parent['ytdReturn']['fmt'];
          break;
      }
    });
    return existSpecsMap;
  }

  static List<String> existSpecs = [
    "Daily Range",
    "52 Week Range",
    "Open",
    "Previous Close",
    "Volume",
    "Volume (24h)",
    "Trailing PE",
    "Forward PE",
    "Market Cap",
    "Avg Daily Vol (10d)",
    "Avg Daily Vol (3mo)",
    "Profit Margin",
    "Trailing EPS",
    "Forward EPS",
    "Book Value",
    "Yield",
    "Earning Date",
    "Ex-dividend Date",
    "Dividend Date",
    "Last Dividend",
    "YTD Return",
  ];

  // TickerSpecs({
  //   this.dailyRange,
  //   this.monthRange,
  //   this.yearRange,
  //   this.openPrice,
  //   this.closePrice,
  //   this.previousClosePrice,
  //   this.volume,
  //   this.trailingPE,
  //   this.forwardPE,
  //   this.marketCap,
  //   this.avgDailyVol10day,
  //   this.avgDailyVol3mo,
  //   this.profitMargin,
  //   this.forwardEPS,
  //   this.trailingEPS,
  //   this.bookValue,
  //   this.yield,
  //   this.beta,
  //   this.earningDate,
  //   this.dividend,
  //   this.lastDividend,
  //   this.YTDReturn,
  // });

}
