import 'package:enos/models/ticker_page_info.dart';
import 'package:enos/models/ticker_tile.dart';
import 'package:enos/services/yahoo_api.dart';

class TickerPageInfo {
  //TickerPageInfo({this.tileData});

  //yahoo api and fill necessary data
  static Future<TickerPageModel> getModelData(
      String symbol, bool isSaved) async {
    YahooApi api = YahooApi();
    print("setting init data");
    TickerTileModel tileModel = await api.get(symbol: symbol);
    tileModel.isSaved = isSaved;
    dynamic result = await api.getTickerData(symbol);
    Map<String, dynamic> compleData = {
      "postPrice": tileModel.isPostMarket
          ? result['price']['postMarketPrice']['fmt']
          : null,
      'shortName': result['quoteType']['shortName'].toString(),
      'marketCloseTime': result['price']['regularMarketTime'],
      'postMarketCloseTime': result['price']['postMarketTime'],
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
