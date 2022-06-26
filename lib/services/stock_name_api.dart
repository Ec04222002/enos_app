import 'dart:convert';

import 'package:enos/models/search_tile.dart';
import 'package:http/http.dart' as http;

class StockNameApi {
  Future<List<SearchTile>> getStock({String query, String market}) async {
    String lowerQuery = query.toLowerCase();
    String lowerMarket = market.toLowerCase();
    int startCode = lowerQuery.codeUnitAt(0);
    String uri = "https://ec04222002.github.io/index_symbols/index.json";
    if (lowerMarket == "otcbb") {
      print("otcbb");
      //A - B
      if (startCode >= 97 && startCode <= 98) {
        uri = "https://ec04222002.github.io/otcbb_AtoB/otcbb_AtoB.json";
      }
      //C - E
      else if (startCode >= 99 && startCode <= 101) {
        uri = "https://ec04222002.github.io/otcbb_CtoE/otcbb_CtoE.json";
      }
      //F - H
      else if (startCode >= 102 && startCode <= 104) {
        uri = "https://ec04222002.github.io/otcbb_FtoH/otcbb_FtoH.json";
      }
      //I to L
      else if (startCode >= 105 && startCode <= 108) {
        uri = "https://ec04222002.github.io/otcbb_ItoL/otcbb_ItoL.json";
      }
      //M to P
      else if (startCode >= 109 && startCode <= 112) {
        uri = "https://ec04222002.github.io/otcbb_MtoP/otcbb_MtoP.json";
      }
      //Q to S
      else if (startCode >= 113 && startCode <= 115) {
        uri = "https://ec04222002.github.io/otcbb_QtoS/otcbb_QtoS.json";
      } else {
        uri = "https://ec04222002.github.io/otcbb_TtoZ/otcbb_TtoZ.json";
      }
    } else if (lowerMarket == "nasdaq") {
      print("nasdaq");
      //A to D
      if (startCode >= 97 && startCode <= 100) {
        uri = "https://ec04222002.github.io/nasdaq_AtoD/nasdaq_AtoD.json";
      }
      //E to M
      else if (startCode >= 101 && startCode <= 109) {
        uri = "https://ec04222002.github.io/nasdaq_EtoM/nasdaq_EtoM.json";
      }
      //N to S
      else if (startCode >= 110 && startCode <= 115) {
        uri = "https://ec04222002.github.io/nasdaq_NtoS/nasdaq_NtoS.json";
      } else {
        uri = "https://ec04222002.github.io/nasdaq_TtoZ/nasdaq_TtoZ.json";
      }
    } else if (lowerMarket == "nyse") {
      print('nyse');
      if (startCode >= 97 && startCode <= 108) {
        uri = "https://ec04222002.github.io/nyse_AtoL/nyse_AtoL.json";
      } else {
        uri = "https://ec04222002.github.io/nyse_MtoZ/nyse_MtoZ.json";
      }
    } else if (lowerMarket == "crypto") {
      print("crypto");
      uri = "https://ec04222002.github.io/crypto_symbols/crypto_symbols.json";
    }
    final url = Uri.parse(uri);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List recs = json.decode(response.body);
      return recs.map((json) => SearchTile.selfApiFromJson(json)).where((item) {
        final symbol = item.symbol.toLowerCase();
        final name = item.name.toLowerCase();
        final search = query.toLowerCase();
        if (lowerMarket == "index") {
          final newSearch = "^" + search;
          return symbol.startsWith(newSearch) || name.startsWith(search);
        }
        return symbol.startsWith(search) || name.startsWith(search);
      }).toList();
    } else {
      throw Exception("Cannot find");
    }
    //if(query.startsWith(pattern))
  }
}
