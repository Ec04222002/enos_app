class SearchTile {
  final String symbol;
  final String name;
  final String market;
  final bool isUser;
  bool isSaved;

  SearchTile(
      {this.symbol, this.name, this.market, this.isUser, this.isSaved = false});

  static SearchTile fromJson(Map<String, dynamic> json) => SearchTile(
        symbol: json['symbol'],
        name: json['shortName'],
        market: json["fullExchangeName"],
        isUser: false,
      );
  static SearchTile selfApiFromJson(Map<String, dynamic> json) =>
      SearchTile(symbol: json['symbol'], name: json['name']);
}
