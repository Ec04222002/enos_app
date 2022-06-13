class TickerTileModel {
  // final String tickerName;
  // final bool isNft;
  // const TickerTileModel({this.tickerName, this.isNft = false});

  final String symbol;
  final String companyName;
  final double price;
  final double percentChange;
  final bool isNft;

  const TickerTileModel(
      {this.symbol,
      this.companyName,
      this.price,
      this.percentChange,
      this.isNft = false});

  static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
      symbol: json['symbol'],
      companyName: json['company_name'],
      price: json['price'],
      percentChange: json['percent_change'],
      isNft: json['is_nft']);

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'company_name': companyName,
        'price': price,
        'percent_change': percentChange,
        'is_nft': isNft,
      };

  // Map<String, dynamic> toJson() => {
  //       'ticker_name': tickerName,
  //       'is_nft': isNft,
  //     };
  // static TickerTileModel fromJson(Map<String, dynamic> json) => TickerTileModel(
  //       tickerName: json['ticker_name'],
  //       isNft: json['is_nft'],
  //     );
}
