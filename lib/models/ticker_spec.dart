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
  static List<String> existSpecs = [
    "Daily Range",
    "52 Week Range",
    "Open",
    "Market Price",
    "Post Market Price",
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
  static Map<String, dynamic> apiToMap(dynamic response) {
    Map<String, dynamic> existSpecsMap = {};
    dynamic parent = response['defaultKeyStatistics'];
    dynamic parent2 = response['summaryDetail'];
    dynamic parent3 = response['price'];
    dynamic parent4 = response['calendarEvents'];
    for (String specs in existSpecs) {
      existSpecsMap[specs] = null;

      //all tickers have these cases
      switch (specs) {
        case "Daily Range":
          existSpecsMap[specs] = parent2['dayLow'] == null
              ? null
              : [
                  parent2['dayLow']['raw'],
                  parent2['dayHigh']['raw'],
                  parent2['dayLow']['fmt'],
                  parent2['dayHigh']['fmt']
                ];

          break;

        case "52 Week Range":
          existSpecsMap[specs] = parent2['fiftyTwoWeekLow'] == null
              ? null
              : [
                  parent2['fiftyTwoWeekLow']['raw'],
                  parent2['fiftyTwoWeekHigh']['raw'],
                  parent2['fiftyTwoWeekLow']['fmt'],
                  parent2['fiftyTwoWeekHigh']['fmt'],
                ];
          break;
        case "Market Cap":
          existSpecsMap[specs] = parent2['marketCap']['fmt'];
          break;
        case "Open":
          existSpecsMap[specs] = parent3['regularMarketOpen']['fmt'];
          break;
        case "Market Price":
          existSpecsMap[specs] = parent3['regularMarketPrice']['raw'];
          break;
        case "Post Market Price":
          existSpecsMap[specs] = parent3['postMarketPrice']['raw'];
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
        case "Avg Daily Vol (10d)":
          existSpecsMap[specs] = parent2['averageDailyVolume10Day']['fmt'];
          break;
        case "Avg Daily Vol (3mo)":
          existSpecsMap[specs] = parent3['averageDailyVolume3Month']['fmt'];
          break;

        case "Ex-dividend Date":
          existSpecsMap[specs] =
              parent4 == null || parent4['exDividendDate'] == null
                  ? null
                  : parent4['exDividendDate']['fmt'];
          break;
        case "Dividend Date":
          existSpecsMap[specs] =
              parent4 == null || parent4['dividendDate'] == null
                  ? null
                  : parent4['dividendDate']['fmt'];
          break;

        default:
          //case is not crypto
          if (response['quoteType']['quoteType'] != "CRYPTOCURRENCY") {
            switch (specs) {
              case "Trailing PE":
                //invalid for crypto and index
                existSpecsMap[specs] = parent2['trailingPE'] == null
                    ? null
                    : parent2['trailingPE']['fmt'];
                break;
              case "Forward PE":
                //invalid for crypto and index
                existSpecsMap[specs] = parent2['forwardPE'] == null
                    ? null
                    : parent2['forwardPE']['fmt'];
                break;

              case "Earning Date":
                existSpecsMap[specs] =
                    (parent4 == null || parent4['earnings'] == null)
                        ? null
                        : parent4['earnings']['earningsDate'][0]['fmt'];
                break;
            }
            if (parent != null) {
              switch (specs) {
                case "Yield":
                  existSpecsMap[specs] = parent['yield']['fmt'];
                  break;
                case "Last Dividend":
                  existSpecsMap[specs] = (parent['lastDividendValue']) == null
                      ? null
                      : parent['lastDividendValue']['fmt'];
                  break;
                case "YTD Return":
                  existSpecsMap[specs] = parent['ytdReturn']['fmt'];
                  break;
                case "Profit Margin":
                  //invalid for crypto and index
                  existSpecsMap[specs] = parent['profitMargins'] == null
                      ? null
                      : "${parent['profitMargins']['raw']} (${parent['profitMargins']['fmt']})";
                  break;
                case "Trailing EPS":
                  //invalid for crypto and index
                  existSpecsMap[specs] = parent['trailingEps'] == null
                      ? null
                      : parent['trailingEps']['fmt'];
                  break;
                case "Forward EPS":
                  //invalid for crypto and index
                  existSpecsMap[specs] = parent['forwardEps'] == null
                      ? null
                      : parent['forwardEps']['fmt'];
                  break;
                case "Book Value":
                  existSpecsMap[specs] = parent['bookValue'] == null
                      ? null
                      : parent['bookValue']['fmt'];
                  break;
              }
            }
          }
      }
    }

    return existSpecsMap;
  }
}
  

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


