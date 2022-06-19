class TickerTileModel {
  final String symbol;
  final String companyName;
  final String price;
  final String percentChange;
  final String postPercentChange;
  final String priceChange;
  final String postPriceChange;

  // bool isNft = false;
  //for saving api calls
  final bool isCrypto;
  final bool isPostMarket;

  bool isLive;
  TickerTileModel(
      {this.symbol,
      this.companyName,
      this.price,
      this.percentChange,
      this.isPostMarket = false,
      this.postPercentChange,
      this.priceChange,
      this.postPriceChange,
      this.isCrypto = false,
      this.isLive = true});

  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
      symbol: json['symbol'] ?? "__",
      companyName: json['company_name'] ?? "____",
      price: json['price'] ?? "___",
      percentChange: json['percent_change'] ?? "__",
      postPercentChange: json['post_percent_change'] ?? "__",
      postPriceChange: json['post_price_change'] ?? "__",
      priceChange: json['price_change'] ?? "__",
      isCrypto: json["is_crypto"],
      isPostMarket: json['is_post_market'],
      isLive: json["is_live"]);

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'company_name': companyName,
        'price': price,
        'percent_change': percentChange,
        'post_percent_change': postPercentChange,
        'post_price_change': postPriceChange,
        'price_change': priceChange,
        'is_crypto': isCrypto,
        'is_post_market': isPostMarket,
        'is_live': isLive,
      };
}
