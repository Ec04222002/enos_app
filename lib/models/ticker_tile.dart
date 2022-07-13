class TickerTileModel {
  final String symbol;
  final String companyName;
  final String price;
  final String percentChange;
  final String postPercentChange;
  final String priceChange;
  final String postPriceChange;
  final double openPrice;
  final List chartDataY;
  final List chartDataX;
  // bool isNft = false;
  //for saving api calls
  final bool isCrypto;
  final bool isPostMarket;
  final String marketName;
  bool isSaved;
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
      this.openPrice,
      this.chartDataX,
      this.chartDataY,
      this.marketName,
      this.isCrypto = false,
      this.isLive = true,
      this.isSaved = false});

  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
      symbol: json['symbol'],
      companyName: json['company_name'],
      price: json['price'],
      percentChange: json['percent_change'],
      postPercentChange: json['post_percent_change'],
      postPriceChange: json['post_price_change'],
      priceChange: json['price_change'],
      openPrice: json["open_price"],
      chartDataX: json['chart_data_x'],
      chartDataY: json["chart_data_y"],
      isCrypto: json["is_crypto"],
      isPostMarket: json['is_post_market'],
      isLive: json["is_live"],
      isSaved: json['is_saved'],
      marketName: json['market_name']);

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'company_name': companyName,
        'price': price,
        'percent_change': percentChange,
        'post_percent_change': postPercentChange,
        'post_price_change': postPriceChange,
        'price_change': priceChange,
        'open_price': openPrice,
        'chart_data_x': chartDataX,
        'chart_data_y': chartDataY,
        'is_crypto': isCrypto,
        'is_post_market': isPostMarket,
        'is_live': isLive,
        'is_saved': isSaved,
        'market_name': marketName,
      };
}
