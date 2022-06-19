class TickerTileModel {
  final String symbol;
  final String companyName;
  final String price;
  final String percentChange;
  // bool isNft = false;
  //for saving api calls
  final bool isPostMarket;
  bool isLive;
  TickerTileModel(
      {this.symbol,
      this.companyName,
      this.price,
      this.percentChange,
      this.isPostMarket = false,
      this.isLive = true});

  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
      symbol: json['symbol'] ?? "__",
      companyName: json['company_name'] ?? "____",
      price: json['price'] ?? "___",
      percentChange: json['percent_change'] ?? "__",
      // isNft: json['is_nft'],
      isPostMarket: json['is_post_market'],
      isLive: json["is_live"]);

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'company_name': companyName,
        'price': price,
        'percent_change': percentChange,
        // 'is_nft': isNft,
        'is_post_market': isPostMarket,
        'is_live': isLive,
      };
}
