class SearchTile {
  final String symbol;
  final String name;
  final String market;
  final bool isUser;
  final double price;
  final double priceChange;
  final double percentChange;
  bool isSaved;

  SearchTile(
      {this.symbol,
      this.name,
      this.market,
      this.isUser,
      this.price,
      this.priceChange,
      this.percentChange,
      this.isSaved = false});

  static SearchTile fromJson(Map<String, dynamic> json) => SearchTile(
        symbol: json['symbol'],
        name: json['shortName'],
        market: json["fullExchangeName"],
        price: json["regularMarketPrice"],
        priceChange: json['regularMarketChange'],
        percentChange: json['regularMarketChangePercent'],
        isUser: false,
      );
  static SearchTile selfApiFromJson(Map<String, dynamic> json) =>
      SearchTile(symbol: json['symbol'], name: json['name']);
}
